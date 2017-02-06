<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:p="urn:local"
    exclude-result-prefixes="xs xd"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>Provides a function to decode %encoded URI parts (as eg. from document-uri)
            <xd:p><xd:b>Created in:</xd:b> 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b>Sean B. Durkin</xd:p>
            <xd:p>http://stackoverflow.com/a/13778818</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:variable name="cp-base" select="string-to-codepoints('0A')" as="xs:integer+" />
    
    <!-- Private function to decode percent-encoded characters  -->
    <xsl:function name="p:pct-decode" as="xs:string?">
        <xsl:param name="toDecode" as="xs:string?"/>
        <xsl:variable name="decodedParts">
            <xsl:analyze-string select="$toDecode" regex="(%[0-9A-F]{{2}})+" flags="i">
                <xsl:matching-substring>
                    <xsl:variable name="utf8-bytes" as="xs:integer+">
                        <xsl:analyze-string select="." regex="%([0-9A-F]{{2}})" flags="i">
                            <xsl:matching-substring>
                                <xsl:variable name="nibble-pair" select="
                                    for $nibble-char in string-to-codepoints( upper-case(regex-group(1))) return
                                    if ($nibble-char ge $cp-base[2]) then
                                    $nibble-char - $cp-base[2] + 10
                                    else
                                    $nibble-char - $cp-base[1]" as="xs:integer+" />
                                <xsl:sequence select="$nibble-pair[1] * 16 + $nibble-pair[2]" />                
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:value-of select="codepoints-to-string( p:utf8decode( $utf8-bytes))" />
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="." />
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join($decodedParts, '')"/>
    </xsl:function>
    
    <xsl:function name="p:utf8decode" as="xs:integer*">
        <xsl:param name="bytes" as="xs:integer*" />
        <xsl:choose>
            <xsl:when test="empty($bytes)" />
            <xsl:when test="$bytes[1] eq 0"><!-- The null character is not valid for XML. -->
                <xsl:sequence select="p:utf8decode( remove( $bytes, 1))" />
            </xsl:when>
            <xsl:when test="$bytes[1] le 127">
                <xsl:sequence select="$bytes[1], p:utf8decode( remove( $bytes, 1))" />
            </xsl:when>
            <xsl:when test="$bytes[1] lt 224">
                <xsl:sequence select="
                    ((($bytes[1] - 192) * 64) +
                    ($bytes[2] - 128)        ),
                    p:utf8decode( remove( remove( $bytes, 1), 1))" />
            </xsl:when>
            <xsl:when test="$bytes[1] lt 240">
                <xsl:sequence select="
                    ((($bytes[1] - 224) * 4096) +
                    (($bytes[2] - 128) *   64) +
                    ($bytes[3] - 128)          ),
                    p:utf8decode( remove( remove( remove( $bytes, 1), 1), 1))" />
            </xsl:when>
            <xsl:when test="$bytes[1] lt 248">
                <xsl:sequence select="
                    ((($bytes[1] - 224) * 262144) +
                    (($bytes[2] - 128) *   4096) +
                    (($bytes[3] - 128) *     64) +
                    ($bytes[4] - 128)            ),
                    p:utf8decode( $bytes[position() gt 4])" />
            </xsl:when>
            <xsl:otherwise>
                <!-- Code-point valid for XML. -->
                <xsl:sequence select="p:utf8decode( remove( $bytes, 1))" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>