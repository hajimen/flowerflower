//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vJAXB 2.1.10 in JDK 6 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2012.05.11 at 07:19:40 午後 JST 
//


package org.kaoriha.flowerflower._20111001;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for specialName.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="specialName">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}normalizedString">
 *     &lt;enumeration value="ABC"/>
 *     &lt;enumeration value="めぐみさん1"/>
 *     &lt;enumeration value="めぐみさん2"/>
 *     &lt;enumeration value="めぐみさん3"/>
 *     &lt;enumeration value="累乗"/>
 *     &lt;enumeration value="おわり"/>
 *     &lt;enumeration value="次回作画像"/>
 *     &lt;enumeration value="次回作へのリンク"/>
 *     &lt;enumeration value="次回作へのマーケットロゴとリンク"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "specialName")
@XmlEnum
public enum SpecialName {

    ABC("ABC"),
    @XmlEnumValue("\u3081\u3050\u307f\u3055\u30931")
    めぐみさん_1("\u3081\u3050\u307f\u3055\u30931"),
    @XmlEnumValue("\u3081\u3050\u307f\u3055\u30932")
    めぐみさん_2("\u3081\u3050\u307f\u3055\u30932"),
    @XmlEnumValue("\u3081\u3050\u307f\u3055\u30933")
    めぐみさん_3("\u3081\u3050\u307f\u3055\u30933"),
    累乗("\u7d2f\u4e57"),
    おわり("\u304a\u308f\u308a"),
    次回作画像("\u6b21\u56de\u4f5c\u753b\u50cf"),
    次回作へのリンク("\u6b21\u56de\u4f5c\u3078\u306e\u30ea\u30f3\u30af"),
    次回作へのマーケットロゴとリンク("\u6b21\u56de\u4f5c\u3078\u306e\u30de\u30fc\u30b1\u30c3\u30c8\u30ed\u30b4\u3068\u30ea\u30f3\u30af");
    private final String value;

    SpecialName(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static SpecialName fromValue(String v) {
        for (SpecialName c: SpecialName.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
