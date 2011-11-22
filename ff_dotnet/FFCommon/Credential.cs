using System;
using System.Collections.Generic;
using System.Text;
using FFCommon.DataSetTableAdapters;

namespace FFCommon
{
    public class Credential
    {
        private string apnsPkcs12FilePath;
        public string ApnsPkcs12FilePath
        {
            get { return apnsPkcs12FilePath; }
            set { apnsPkcs12FilePath = value; }
        }
        public readonly static string ApnsPkcs12FilePathKind = "ApnsPkcs12FilePath";

        private string apnsPkcs12FilePassword;
        public string ApnsPkcs12FilePassword
        {
            get { return apnsPkcs12FilePassword; }
            set { apnsPkcs12FilePassword = value; }
        }
        public readonly static string ApnsPkcs12FilePasswordKind = "ApnsPkcs12FilePassword";

        private bool apnsIsSandbox = true;
        public bool ApnsIsSandbox
        {
            get { return apnsIsSandbox; }
            set { apnsIsSandbox = value; }
        }
        public readonly static string ApnsIsSandboxKind = "ApnsIsSandbox";

        private string lvlRsaKeyValue;
        public string LvlRsaKeyValue
        {
            get { return lvlRsaKeyValue; }
            set { lvlRsaKeyValue = value; }
        }
        public readonly static string LvlRsaKeyValueKind = "LvlRsaKeyValue";

        private string lvlPackageName;
        public string LvlPackageName
        {
            get { return lvlPackageName; }
            set { lvlPackageName = value; }
        }
        public readonly static string LvlPackageNameKind = "LvlPackageName";

        public Credential()
        {
        }

        public Credential(DataSet.TitleRow title)
        {
            CredentialTableAdapter ta = new CredentialTableAdapter();
            foreach (DataSet.CredentialRow row in ta.GetDataByTitleId(title.Id))
            {
                if (row.Kind == ApnsPkcs12FilePathKind)
                {
                    apnsPkcs12FilePath = row.Body;
                }
                else if (row.Kind == ApnsPkcs12FilePasswordKind)
                {
                    apnsPkcs12FilePassword = row.Body;
                }
                else if (row.Kind == ApnsIsSandboxKind)
                {
                    apnsIsSandbox = bool.Parse(row.Body);
                }
                else if (row.Kind == LvlRsaKeyValueKind)
                {
                    lvlRsaKeyValue = row.Body;
                }
                else if (row.Kind == LvlPackageNameKind)
                {
                    lvlPackageName = row.Body;
                }
            }
        }

        public static bool operator !=(Credential l, Credential r)
        {
            return !(l == r);
        }

        public static bool operator ==(Credential l, Credential r)
        {
            if (System.Object.ReferenceEquals(l, r))
            {
                return true;
            }

            // If one is null, but not both, return false.
            if (((object)l == null) || ((object)l == null))
            {
                return false;
            }

            return l.Equals(r);
        }

        public override bool Equals(Object obj)
        {
            // If parameter is null return false.
            if (obj == null)
            {
                return false;
            }

            // If parameter cannot be cast to Point return false.
            Credential c = obj as Credential;
            if ((Object)c == null)
            {
                return false;
            }

            // Return true if the fields match:
            return (apnsPkcs12FilePath == c.apnsPkcs12FilePath)
                && (apnsPkcs12FilePassword == c.apnsPkcs12FilePassword)
                && (apnsIsSandbox == c.apnsIsSandbox)
                && (lvlRsaKeyValue == c.lvlRsaKeyValue)
                && (lvlPackageName == c.lvlPackageName);
        }

        public override int GetHashCode()
        {
            return NullSafeHashCode(apnsPkcs12FilePath) ^ NullSafeHashCode(apnsPkcs12FilePassword)
                ^ NullSafeHashCode(apnsIsSandbox) ^ NullSafeHashCode(lvlRsaKeyValue) ^ NullSafeHashCode(lvlPackageName);
        }


        private static int NullSafeHashCode(object o)
        {
            if (o == null)
                return 0;
            else
                return o.GetHashCode();
        }
    }
}
