<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">



    <xsl:template match="node()|@*">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>

    <xsl:strip-space elements="*"/>

    <xsl:template match="Parole">

        <xsl:comment>PREDICATE</xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
       <!-- <xsl:apply-templates
            select="ParoleSemant/SemU/PredicativeRepresentation[@typeoflink = 'MASTER']"/> -->
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:comment>SYN SEM</xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
      <!--  <xsl:apply-templates select="ParoleSyntaxe/SynU/CorrespSynUSemU"/> -->
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:comment>DESCRIPTION /positions</xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    <!--    <xsl:apply-templates select="ParoleSyntaxe/Description"/> -->
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:comment>POSITIONS</xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
     <!--   <xsl:apply-templates select="ParoleSyntaxe/PositionC"/>-->
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:comment>SYNTAGMAS</xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    <!--    <xsl:apply-templates select="ParoleSyntaxe/SyntagmaNTC"/> -->
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

/Parole/ParoleSemant[1]/RSemU[12]
        <xsl:comment>SEMANTIC RELATIONS</xsl:comment>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="ParoleSemant/RSemU"/> 
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>

    </xsl:template>


    <xsl:template match="Parole/ParoleSemant/RSemU">
        
        <xsl:text>parole:semanticRelation</xsl:text><xsl:value-of select="substring(@id,3)"/><xsl:text> rdf:type owl:ObjectProperty ;&#10;</xsl:text>
        <xsl:text>&#9;rdfs:subPropertyOf lemon:senseRelation ;&#10;</xsl:text>
        <xsl:text>&#9;dc:creator "Parole/Simple Project" ;&#10;</xsl:text>
        <xsl:for-each select="@*">
           
        <xsl:choose>
            <xsl:when test="name() = 'example'">
                <xsl:text>&#9;dc:example "</xsl:text><xsl:value-of select="."/><xsl:text>" ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="name() = 'comment'">
                <xsl:text>&#9;dc:description "</xsl:text><xsl:value-of select="."/><xsl:text>" ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="name() = 'isal'">
                <xsl:text>&#9;rdfs:subPropertyOf parole:semanticRelation</xsl:text><xsl:value-of select="substring(.,3)"/><xsl:text> ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="name() = 'invsemr'">
                <xsl:text>&#9;owl:inverseOf parole:semanticRelation</xsl:text><xsl:value-of select="substring(.,3)"/><xsl:text> ;&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
            </xsl:for-each>
        <xsl:text>.&#10;</xsl:text>
        
    </xsl:template>
    


    <xsl:template match="Parole/ParoleSemant/SemU/PredicativeRepresentation[@typeoflink = 'MASTER']">

        <xsl:variable name="predicate" select="./@predicate"/>

        <xsl:apply-templates select="//Predicate[@id = $predicate]">
            <xsl:with-param name="semu" select="../@id"/>
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="Parole/ParoleSemant/Predicate">
        <xsl:param name="semu"/>
        <!-- template to get all arguments in argumentl -->
        <xsl:value-of select="$semu"/>
        <xsl:text> = </xsl:text>
        <xsl:call-template name="proc_call_by_Argument">
            <xsl:with-param name="ids_string" select="@argumentl"/>
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>

    </xsl:template>


    <!-- Template that calls Arguments in argumnetl -->

    <xsl:template name="proc_call_by_Argument">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>

        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//Argument[@id = $ids_string]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//Argument[@id = $id_str]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_Argument">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Parole/ParoleSemant/Argument">

        <xsl:value-of select="@semanticrolel"/>
        <xsl:if test="@informargl">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@informargl"/>
        </xsl:if>

        <xsl:text>;</xsl:text>
    </xsl:template>


    <xsl:template match="Parole/ParoleSyntaxe/SynU/CorrespSynUSemU">

        <xsl:choose>
            <xsl:when test="./@description">
                <!-- &#x9;&#x9;del corresp <xsl:value-of select="./@description"/> -->
                <xsl:value-of select="@targetsemu"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="../@id"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="./@description"/>

                <xsl:text>&#10;</xsl:text>
            </xsl:when>

            <xsl:otherwise>
                <!-- &#x9;&#x9;de la synu <xsl:value-of select="../@description"/> -->
                <xsl:value-of select="@targetsemu"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="../@id"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="../@description"/>

                <xsl:text>&#10;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>



    <xsl:template match="Parole/ParoleSyntaxe/SyntagmaNTC">
        <!--<xsl:call-template name="att2feats"/>-->

        <xsl:value-of select="@id"/>
        <xsl:text> :: </xsl:text>
        <xsl:text>parole:syntlabel=</xsl:text>
        <xsl:value-of select="@syntlabel"/>
        <xsl:text>;</xsl:text>
        <xsl:for-each select="./SyntFeatureClosed">
            <xsl:text>parole:</xsl:text>
            <xsl:value-of select="@featurename"/>
            <xsl:text>=</xsl:text>
            <xsl:text>parole:</xsl:text>
            <xsl:value-of select="@value"/>
            <xsl:text>;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="./SyntFeatureOpen">
            <xsl:text>parole:</xsl:text>
            <xsl:value-of select="@featurename"/>
            <xsl:text>=</xsl:text>
            <xsl:text>parole:</xsl:text>
            <xsl:value-of select="@value"/>

            <xsl:text>;</xsl:text>
        </xsl:for-each>
        <xsl:if test="@featurel">
            <xsl:text>parole:featurel</xsl:text>

            <xsl:text>=</xsl:text>
            <xsl:text>parole:</xsl:text>
            <xsl:value-of select="@featurel"/>
            <xsl:text>;</xsl:text>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <xsl:template match="Parole/ParoleSyntaxe/PositionC">
        <xsl:value-of select="@id"/>
        <xsl:text> :: </xsl:text>
        <xsl:text>parole:function=</xsl:text>
        <xsl:value-of select="@function"/>
        <xsl:text>;syntagmas=</xsl:text>
        <xsl:value-of select="@syntagmacl"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>



    <xsl:template match="Parole/ParoleSyntaxe/Description">

        <xsl:value-of select="@id"/>
        <xsl:text>=</xsl:text>

        <xsl:variable name="construction" select="@construction"/>
        <xsl:apply-templates select="//Construction[@id = $construction]"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <xsl:template match="Parole/ParoleSyntaxe/Construction">

        <xsl:for-each select="./InstantiatedPositionC">
            <xsl:value-of select="./@positionc"/>;</xsl:for-each>
    </xsl:template>

    <!-- general template that maps all Parole attributes to feat nodes -->

    <xsl:template name="att2feats">
        <xsl:for-each select="@*">
            <feat>
                <xsl:attribute name="att">
                    <xsl:value-of select="name()"/>
                </xsl:attribute>
                <xsl:attribute name="val">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </feat>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
