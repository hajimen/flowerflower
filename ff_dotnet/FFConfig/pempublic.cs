//**********************************************************************
//
// pempublic
// .NET 1.1/2.0  PEM SubjectPublicKeyInfo Public Key Reader
//
// Copyright (C) 2006  	JavaScience Consulting
//
//**********************************************************************
//
// pempublic.c
//
// Reads a PEM encoded in b64 format (with or without header/footer
// lines) or binary RSA public key file in SubjectPublicKeyInfo asn.1 format.
// Removes header/footer lines and b64 decodes for b64 case.
// Parses asn.1 encoding to extract exponent and modulus byte[].
// Creates byte[] modulus and byte[] exponent
// Instantiates RSACryptoServiceProvider
//*************************************************************************
//
// Modified 2011/10/16 NAKAZATO Hajime, Nishizaike Kaoriha
//*************************************************************************
using System;
using System.IO;
using System.Text;
using System.Security.Cryptography;

public class pempublic
{

    // encoded OID sequence for  PKCS #1 rsaEncryption szOID_RSA_RSA = "1.2.840.113549.1.1.1"
    static byte[] SeqOID = { 0x30, 0x0D, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01, 0x05, 0x00 };

    public static void Entry(String filestr, ref String xmlpublickey)
    {
        byte[] x509key;
        byte[] seq = new byte[15];
        int x509size;
/*
        if (filename == "")  //exit while(true) loop
            return;
        if (!File.Exists(filename))
        {
            throw new FileNotFoundException("File does not exist!\n");
        }

        StreamReader sr = File.OpenText(filename);
        String filestr = sr.ReadToEnd();
        sr.Close();
*/
        StringBuilder sb = new StringBuilder(filestr);
        sb.Replace("-----BEGIN PUBLIC KEY-----", "");  //remove headers/footers, if present
        sb.Replace("-----END PUBLIC KEY-----", "");

        try
        {        //see if the file is a valid Base64 encoded cert
            x509key = Convert.FromBase64String(sb.ToString());
        }
        catch (System.FormatException)
        {		//if not a b64-encoded publiccert, assume it's binary
//            Console.WriteLine("Not a valid  b64 blob; assume binary");
//            Stream stream = new FileStream(filename, FileMode.Open);
//            int datalen = (int)stream.Length;
//            x509key = new byte[datalen];
//            stream.Read(x509key, 0, datalen);
//            stream.Close();
            return;

        }
        x509size = x509key.Length;

        //Console.WriteLine(sb.ToString()) ;
        //PutFileBytes("x509key", x509key, x509key.Length) ;

        // ---------  Set up stream to read the asn.1 encoded SubjectPublicKeyInfo blob  ------
        MemoryStream mem = new MemoryStream(x509key);
        BinaryReader binr = new BinaryReader(mem);    //wrap Memory Stream with BinaryReader for easy reading
        byte bt = 0;
        ushort twobytes = 0;

        try
        {

            twobytes = binr.ReadUInt16();
            if (twobytes == 0x8130)	//data read as little endian order (actual data order for Sequence is 30 81)
                binr.ReadByte();	//advance 1 byte
            else if (twobytes == 0x8230)
                binr.ReadInt16();	//advance 2 bytes
            else
                return;

            seq = binr.ReadBytes(15);		//read the Sequence OID
            if (!CompareBytearrays(seq, SeqOID))	//make sure Sequence for OID is correct
                return;

            twobytes = binr.ReadUInt16();
            if (twobytes == 0x8103)	//data read as little endian order (actual data order for Bit String is 03 81)
                binr.ReadByte();	//advance 1 byte
            else if (twobytes == 0x8203)
                binr.ReadInt16();	//advance 2 bytes
            else
                return;

            bt = binr.ReadByte();
            if (bt != 0x00)		//expect null byte next
                return;

            twobytes = binr.ReadUInt16();
            if (twobytes == 0x8130)	//data read as little endian order (actual data order for Sequence is 30 81)
                binr.ReadByte();	//advance 1 byte
            else if (twobytes == 0x8230)
                binr.ReadInt16();	//advance 2 bytes
            else
                return;

            twobytes = binr.ReadUInt16();
            byte lowbyte = 0x00;
            byte highbyte = 0x00;

            if (twobytes == 0x8102)	//data read as little endian order (actual data order for Integer is 02 81)
                lowbyte = binr.ReadByte();	// read next bytes which is bytes in modulus
            else if (twobytes == 0x8202)
            {
                highbyte = binr.ReadByte();	//advance 2 bytes
                lowbyte = binr.ReadByte();
            }
            else
                return;
            byte[] modint = { lowbyte, highbyte, 0x00, 0x00 };   //reverse byte order since asn.1 key uses big endian order
            int modsize = BitConverter.ToInt32(modint, 0);

            int firstbyte = binr.PeekChar();
            if (firstbyte == 0x00)
            {	//if first byte (highest order) of modulus is zero, don't include it
                binr.ReadByte();	//skip this null byte
                modsize -= 1;	//reduce modulus buffer size by 1
            }

            byte[] modulus = binr.ReadBytes(modsize);	//read the modulus bytes

            if (binr.ReadByte() != 0x02)			//expect an Integer for the exponent data
                return;
            int expbytes = (int)binr.ReadByte();		// should only need one byte for actual exponent data (for all useful values)
            byte[] exponent = binr.ReadBytes(expbytes);


            showBytes("\nExponent", exponent);
            showBytes("\nModulus", modulus);

            // ------- create RSACryptoServiceProvider instance and initialize with public key -----
            RSACryptoServiceProvider RSA = new RSACryptoServiceProvider();
            RSAParameters RSAKeyInfo = new RSAParameters();
            RSAKeyInfo.Modulus = modulus;
            RSAKeyInfo.Exponent = exponent;
            RSA.ImportParameters(RSAKeyInfo);

            xmlpublickey = RSA.ToXmlString(false);
            // Console.WriteLine("XML encoded RSA public key:\n{0}", xmlpublickey);
        }

        finally
        {
            binr.Close();
        }
    }




    private static bool CompareBytearrays(byte[] a, byte[] b)
    {
        if (a.Length != b.Length)
            return false;
        int i = 0;
        foreach (byte c in a)
        {
            if (c != b[i])
                return false;
            i++;
        }
        return true;
    }



    private static void showBytes(String info, byte[] data)
    {
        Console.WriteLine("{0}  [{1} bytes]", info, data.Length);
        for (int i = 1; i <= data.Length; i++)
        {
            Console.Write("{0:X2}  ", data[i - 1]);
            if (i % 16 == 0)
                Console.WriteLine();
        }
        Console.WriteLine();
    }


    private static void PutFileBytes(String outfile, byte[] data, int bytes)
    {
        FileStream fs = null;
        if (bytes > data.Length)
        {
            Console.WriteLine("Too many bytes");
            return;
        }
        try
        {
            fs = new FileStream(outfile, FileMode.Create);
            fs.Write(data, 0, bytes);
        }
        catch (Exception e)
        {
            Console.WriteLine(e.Message);
        }
        finally
        {
            fs.Close();
        }
    }

}
