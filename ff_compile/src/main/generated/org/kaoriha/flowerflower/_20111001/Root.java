//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vJAXB 2.1.10 in JDK 6 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2012.03.05 at 11:36:20 午前 JST 
//


package org.kaoriha.flowerflower._20111001;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded">
 *         &lt;group ref="{http://kaoriha.org/flowerflower/20111001/}rootGroup"/>
 *       &lt;/choice>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "pOrSpecialOrChapter"
})
@XmlRootElement(name = "root")
public class Root {

    @XmlElements({
        @XmlElement(name = "footnote", type = Footnote.class),
        @XmlElement(name = "p", type = P.class),
        @XmlElement(name = "chapter", type = Chapter.class),
        @XmlElement(name = "section", type = Section.class),
        @XmlElement(name = "characterNote", type = CharacterNote.class),
        @XmlElement(name = "special", type = Special.class),
        @XmlElement(name = "separation", type = Separation.class)
    })
    protected List<Object> pOrSpecialOrChapter;

    /**
     * Gets the value of the pOrSpecialOrChapter property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the pOrSpecialOrChapter property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getPOrSpecialOrChapter().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Footnote }
     * {@link P }
     * {@link Chapter }
     * {@link Section }
     * {@link CharacterNote }
     * {@link Special }
     * {@link Separation }
     * 
     * 
     */
    public List<Object> getPOrSpecialOrChapter() {
        if (pOrSpecialOrChapter == null) {
            pOrSpecialOrChapter = new ArrayList<Object>();
        }
        return this.pOrSpecialOrChapter;
    }

}
