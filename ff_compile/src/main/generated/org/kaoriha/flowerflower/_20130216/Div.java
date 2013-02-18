//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.4-2 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2013.02.18 at 03:39:29 PM JST 
//


package org.kaoriha.flowerflower._20130216;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElementRef;
import javax.xml.bind.annotation.XmlElementRefs;
import javax.xml.bind.annotation.XmlMixed;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.NormalizedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;group ref="{http://kaoriha.org/flowerflower/20130216/}rootGroup"/>
 *       &lt;/choice>
 *       &lt;attribute name="class" type="{http://www.w3.org/2001/XMLSchema}normalizedString" />
 *       &lt;attribute name="style" type="{http://www.w3.org/2001/XMLSchema}normalizedString" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "content"
})
@XmlRootElement(name = "div")
public class Div {

    @XmlElementRefs({
        @XmlElementRef(name = "characterNote", namespace = "http://kaoriha.org/flowerflower/20130216/", type = CharacterNote.class, required = false),
        @XmlElementRef(name = "raw", namespace = "http://kaoriha.org/flowerflower/20130216/", type = Raw.class, required = false),
        @XmlElementRef(name = "div", namespace = "http://kaoriha.org/flowerflower/20130216/", type = Div.class, required = false),
        @XmlElementRef(name = "footnote", namespace = "http://kaoriha.org/flowerflower/20130216/", type = Footnote.class, required = false),
        @XmlElementRef(name = "separation", namespace = "http://kaoriha.org/flowerflower/20130216/", type = Separation.class, required = false),
        @XmlElementRef(name = "chapter", namespace = "http://kaoriha.org/flowerflower/20130216/", type = Chapter.class, required = false),
        @XmlElementRef(name = "text", namespace = "http://kaoriha.org/flowerflower/20130216/", type = Text.class, required = false),
        @XmlElementRef(name = "section", namespace = "http://kaoriha.org/flowerflower/20130216/", type = Section.class, required = false)
    })
    @XmlMixed
    protected List<Object> content;
    @XmlAttribute(name = "class")
    @XmlJavaTypeAdapter(NormalizedStringAdapter.class)
    @XmlSchemaType(name = "normalizedString")
    protected String clazz;
    @XmlAttribute(name = "style")
    @XmlJavaTypeAdapter(NormalizedStringAdapter.class)
    @XmlSchemaType(name = "normalizedString")
    protected String style;

    /**
     * Gets the value of the content property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the content property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getContent().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CharacterNote }
     * {@link String }
     * {@link Raw }
     * {@link Div }
     * {@link Footnote }
     * {@link Separation }
     * {@link Text }
     * {@link Chapter }
     * {@link Section }
     * 
     * 
     */
    public List<Object> getContent() {
        if (content == null) {
            content = new ArrayList<Object>();
        }
        return this.content;
    }

    /**
     * Gets the value of the clazz property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getClazz() {
        return clazz;
    }

    /**
     * Sets the value of the clazz property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setClazz(String value) {
        this.clazz = value;
    }

    /**
     * Gets the value of the style property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStyle() {
        return style;
    }

    /**
     * Sets the value of the style property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStyle(String value) {
        this.style = value;
    }

}