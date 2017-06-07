<?xml version="1.0" encoding="UTF-8"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:template match="node()|@*">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>
    <xsl:strip-space elements="*"/>

    <xsl:template match="Parole">
        <xsl:text>&#10;&#10;</xsl:text>

        <xsl:text>### (1) Lexical entries ########################</xsl:text>
       <!-- <xsl:text>&#10;&#10;</xsl:text>
        <xsl:apply-templates select="ParoleMorpho"/>
        <xsl:text>&#10;&#10;</xsl:text> -->


        <xsl:text>### (2) Senses ########################</xsl:text>
    <!--    <xsl:text>&#10;&#10;</xsl:text>
       <xsl:apply-templates select="ParoleSemant/SemU" mode="Sense"/>
        <xsl:text>&#10;&#10;</xsl:text> -->

        <xsl:text>### (3) argument structure ########################</xsl:text>
      <!--  <xsl:text>&#10;&#10;</xsl:text>
        <xsl:apply-templates
            select="ParoleSemant/SemU/PredicativeRepresentation[@typeoflink = 'Master']"/>
        <xsl:text>&#10;&#10;</xsl:text> -->

        <xsl:text>### (4) Syntactic Frames ########################</xsl:text>
        <!-- Syntax Frames ONLY VERBS test=DescV-->
        <!--<xsl:text>&#10;&#10;## Top Frames &#10;&#10;</xsl:text>
        <xsl:apply-templates select="ParoleSyntaxe/Description" mode="top"/> -->
        <xsl:text>&#10;&#10;## instance Frames&#10;&#10;</xsl:text>
        <xsl:apply-templates select="ParoleSyntaxe/SynU" mode="Frame"/> 
        <xsl:text>&#10;&#10;</xsl:text> 
    </xsl:template>

    <!-- ################### Templates ########################### -->

    <!-- RDF ParoleMorpho (simply calls MuS) ..............................................................-->
    <xsl:template match="ParoleMorpho">
        <xsl:apply-templates select="MuS"/>
    </xsl:template>

    <!-- (1) RDF MuS (writes MuS=LexicalEntry & call Synus if VERB syntacticBhaviour & calls SemU to get 'senses' )-->
    <xsl:template match="MuS">
        <xsl:text>lex:</xsl:text>
        <xsl:value-of select="./Gmu/Spelling"/>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="./@gramcat"/>
        <xsl:text> a lemon:LexicalEntry ;&#10;</xsl:text>
        <xsl:text>&#x9;rdfs:label "</xsl:text>
        <xsl:value-of select="./Gmu/Spelling"/>
        <xsl:text>" ;&#10;</xsl:text>
        <xsl:text>&#x9;lemon:form [ lemon:writtenRep "</xsl:text>
        <xsl:value-of select="./Gmu/Spelling"/>
        <xsl:text>"@es ] ;</xsl:text>
        <xsl:call-template name="att2feats"/>

        <!-- (1.1) syntacticBehaviour  ONLY VERBS !!!!!!!!!!!!!!-->

        <xsl:if test="./@gramcat = 'VERB'">
            <xsl:call-template name="proc_call_by_id">
                <xsl:with-param name="ids_string" select="@synulist"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:text>.&#10;</xsl:text>
        <!-- (1.2) sense  !!!!!!!!!!!!!!-->
        <xsl:variable name="mus">
            <xsl:value-of select="./Gmu/Spelling"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="./@gramcat"/>
        </xsl:variable>
        <xsl:call-template name="proc_call_by_SemUid">
            <xsl:with-param name="mus" select="$mus"/>
            <xsl:with-param name="ids_string" select="@synulist"/>
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <!-- (1.1) RDF: Template that looks for the set of SynUs in synulist. 
        it calls the SynU Template that builds the SyntacticBehaviour part of the LexicalEntry -->

    <xsl:template name="proc_call_by_id">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>

        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//SynU[@id = $ids_string]" mode="LexicalEntry"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//SynU[@id = $id_str]" mode="LexicalEntry"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_id">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- (1.1) RDF -->
    <xsl:template match="Parole/ParoleSyntaxe/SynU" mode="LexicalEntry">
        <xsl:apply-templates select="." mode="print_value"/>
        <xsl:text>&#x9;lemon:synBehavior lex:</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="@description"/>
        <xsl:text>;</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:if test="@descriptionl">
            <xsl:call-template name="proc_call_by_DescriptionlID0">
                <xsl:with-param name="ids_string" select="@descriptionl"/>
                <xsl:with-param name="synuID" select="@id"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    <!-- (1.1) RDF -->
    <xsl:template name="proc_call_by_DescriptionlID0">
        <xsl:param name="ids_string"/>
        <xsl:param name="synuID"/>

        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>
        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:text>&#x9;lemon:synBehavior lex:</xsl:text>
                <xsl:value-of select="$synuID"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="$ids_string"/>
                <xsl:text>;&#10;</xsl:text>

            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#x9;lemon:synBehavior lex:</xsl:text>
                <xsl:value-of select="$synuID"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="$id_str"/>
                <xsl:text>;&#10;</xsl:text>

            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_DescriptionlID0">
                <xsl:with-param name="ids_string" select="$id_rest"/>
                <xsl:with-param name="synuID" select="$synuID"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>



    <!-- (1.2) (Called by MuS) RDF: Template that looks for the set of SemUs in CorrespSynUSemU/@targetsemu. 
        it calls the SemU Template that builds the sense part of the LexicalEntry -->

    <xsl:template name="proc_call_by_SemUid">
        <xsl:param name="mus"/>
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>
        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//SynU[@id = $ids_string]/CorrespSynUSemU">
                    <xsl:with-param name="synu" select="$ids_string"/>
                    <xsl:with-param name="mus" select="$mus"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//SynU[@id = $id_str]/CorrespSynUSemU">
                    <xsl:with-param name="synu" select="$id_str"/>
                    <xsl:with-param name="mus" select="$mus"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_SemUid">
                <xsl:with-param name="ids_string" select="$id_rest"/>
                <xsl:with-param name="mus" select="$mus"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- (1.2) (Called by MuS - proc_call_by_SemUid) RDF Semantics: gets SemU id, looks for SemU element 
        and builds the corresponding LMF Sense node -->

    <xsl:template match="CorrespSynUSemU">
        <xsl:param name="synu"/>
        <xsl:param name="mus"/>
        <xsl:variable name="has_id" select="@targetsemu"/>
        <!-- checks if 'targetsemu' was already referenced by preceeding CorrespSynUSemU to avoid duplicates -->
        <xsl:if test="not (preceding::CorrespSynUSemU[@targetsemu=$has_id])">
            <xsl:variable name="id_string" select="@targetsemu"/>
            <xsl:apply-templates select="//SemU[@id=$id_string]" mode="LexicalEntry">

                <xsl:with-param name="synu" select="$synu"/>
                <xsl:with-param name="mus" select="$mus"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!-- (1.2) RDF  (Called by MuS - CorrespSynUSemU)-->
    <xsl:template match="Parole/ParoleSemant/SemU" mode="LexicalEntry">
        <xsl:param name="synu"/>
        <xsl:param name="mus"/>
        <xsl:text>lex:</xsl:text>
        <xsl:value-of select="$mus"/>
        <xsl:text> lemon:sense lex:</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text> .</xsl:text>
        <xsl:text>&#10;</xsl:text>

        <xsl:choose>
          <!--  <xsl:when test="//SynU[@id=$synu]/@description = 'DescDetCalendN'"> OJO
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:CalendarNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DescDetCountN'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:CountableNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DescDetMassN'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:MassNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DescDetUncountN'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:UncountableNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DescDetPluralN'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:PuralNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DescDetNcomp'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> lemon:synBehavior lex:</xsl:text>
                <xsl:value-of select="@description"/>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when> -->

            <xsl:when test="//SynU[@id=$synu]/@description = 'DNCalend'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:CalendarNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DNCount'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:CountableNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DNMass'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:MassNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DNNocount'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:UncountableNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DNPlcount'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:PuralNoun ; parole:countability parole:CountableNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DNPlnocount'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:PuralNoun ; parole:countability parole:UncountableNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DNPlmass'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:countability parole:PuralNoun ; parole:countability parole:MassNoun</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="//SynU[@id=$synu]/@description = 'DNComp'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> lemon:synBehavior lex:</xsl:text>
                <xsl:value-of select="@description"/>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
        </xsl:choose>

        <!-- adjectives -->
        <xsl:if test="substring(//SynU[@id=$synu]/@description,1,7)  = 'DescAdj'">
            <xsl:if test="substring(//SynU[@id=$synu]/@description,1,12)  = 'DescAdjestar'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:copulaType parole:CopulaEstar</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if test="substring(//SynU[@id=$synu]/@description,1,10)  = 'DescAdjser'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:copulaType parole:CopulaSer</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>

            <xsl:if
                test="substring(//SynU[@id=$synu]/@description, (string-length(//SynU[@id=$synu]/@description) - 2) + 1) = 'NQ'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text> parole:gradable parole:NonGradable</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
          
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    <!-- END Of Mus derived templates ....................................................................................................-->



    <!-- (2.) RDF  Builds the LexicalSense part .................................................................................................-->
    <xsl:template match="Parole/ParoleSemant/SemU" mode="Sense">
        <xsl:text>lex:</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text> a lemon:LexicalSense ;</xsl:text>
        <xsl:call-template name="att2feats"/>
        <!-- template to get all WeightValSemFeatures -->

        <xsl:call-template name="proc_call_by_WeightValSemFeatureid">
            <xsl:with-param name="ids_string" select="@weightvalsemfeaturel"/>
        </xsl:call-template>
        <!-- RWeightValSemU -->
        <xsl:for-each select="./RWeightValSemU">
            <xsl:text>&#x9;parole:</xsl:text>
            <xsl:value-of select="@semr"/>
            <xsl:text> lex:</xsl:text>
            <xsl:value-of select="@target"/>
            <xsl:text> ;&#10;</xsl:text>
        </xsl:for-each>
        <xsl:text>.</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- (2) RDF Template that looks for the set of WeightValSemFeature in weightvalsemfeaturel.  -->

    <xsl:template name="proc_call_by_WeightValSemFeatureid">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>

        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:call-template name="SemFeatures">
                    <xsl:with-param name="id" select="$ids_string"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="SemFeatures">
                    <xsl:with-param name="id" select="$id_str"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_WeightValSemFeatureid">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- (2.) RDF: WeightValSemFeature ValSemFeature *[substring(name(), string-length() -3) = 'line'] -->

    <xsl:template name="SemFeatures">
        <xsl:param name="id"/>
        <xsl:choose>
            <xsl:when test="substring($id, string-length($id) -26 ) = '_TS_classificateur_de_nom_C'">
                <xsl:text>&#x9;parole:semanticClass parole:SemClass</xsl:text>
                <xsl:value-of select="substring($id,6,string-length($id) - 32)"/>
                <xsl:text> ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -26 ) = '_TS_classificateur_de_verbe'">
                <xsl:text>&#x9;parole:semanticClass parole:SemClass</xsl:text>
                <xsl:value-of select="substring($id,6,string-length($id) - 32)"/>
                <xsl:text> ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -12 ) = '_TS_domaine_D'">
                <xsl:text>&#x9;parole:domain parole:Dom</xsl:text>
                <xsl:value-of select="substring($id,6,string-length($id) - 19)"/>
                <xsl:text> ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, 1, 21 ) = 'WVSFTemplateSuperType'"> </xsl:when>
            <xsl:when test="substring($id, 1, 24 ) = 'WVSFTemplateADJSuperType'"> </xsl:when>
            <xsl:when test="substring($id, 1, 15 ) = 'WVSFTemplateADJ'">
                <xsl:text>&#x9;parole:template parole:Templ</xsl:text>
                <xsl:value-of
                    select="substring(substring($id,13), 1, string-length(substring($id,13)))"/>
                <xsl:text> ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, 1, 12 ) = 'WVSFTemplate'">
                <xsl:text>&#x9;parole:template parole:Templ</xsl:text>
                <xsl:value-of
                    select="substring(substring($id,13), 1, string-length(substring($id,13))- 4)"/>
                <xsl:text> ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, 1, 13 ) = 'TSVP_PLUS_TS_'">
                <xsl:text>&#x9;parole:semanticFeature parole:SemanticFeature</xsl:text>
                <xsl:value-of
                    select="substring(substring($id,14), 1, string-length(substring($id,14))- 2)"/>
                <xsl:text> ; &#10;</xsl:text>
            </xsl:when>

            <xsl:when test="substring($id, string-length($id) -7 ) = 'Positive'">
                <xsl:text>&#x9;parole:connotation parole:Positive ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -7 ) = 'Negative'">
                <xsl:text>&#x9;parole:connotation parole:Negative ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -11 ) = 'PositivePROT'">
                <xsl:text>&#x9;parole:connotation parole:Positive ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -11 ) = 'NegativePROT'">
                <xsl:text>&#x9;parole:connotation parole:Negative ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -10 ) = 'PositiveESS'">
                <xsl:text>&#x9;parole:connotation parole:Positive ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -10 ) = 'NegativeESS'">
                <xsl:text>&#x9;parole:connotation parole:Negative ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -6 ) = 'Neutral'">
                <xsl:text>&#x9;parole:connotation parole:Neutral ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -13 ) = 'Underspecified'">
                <xsl:text>&#x9;parole:connotation parole:Underspecified ; &#10;</xsl:text>
            </xsl:when>

            <xsl:when test="substring($id, string-length($id) -7 ) = 'AttrPROT'">
                <xsl:text>&#x9;parole:adjType parole:AttributiveAdjective ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -7 ) = 'PredPROT'">
                <xsl:text>&#x9;parole:adjType parole:PredicativeAdjective ; &#10;</xsl:text>
            </xsl:when>
            <xsl:when test="substring($id, string-length($id) -11 ) = 'AttrPredPROT'">
                <xsl:text>&#x9;parole:adjType parole:AttributivePredicativeAdjective ; &#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- End of LexicalSense ########################################################## -->



    <!-- (3.) RDF Argument structure ##########################################################-->

    <xsl:template match="Parole/ParoleSemant/SemU/PredicativeRepresentation[@typeoflink = 'Master']"> <!-- OJO MASTER -->
        <xsl:variable name="predicate" select="./@predicate"/>
        <xsl:apply-templates select="//Predicate[@id = $predicate]">
            <xsl:with-param name="semu" select="../@id"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- (3.) -->
    <xsl:template match="Parole/ParoleSemant/Predicate">
        <xsl:param name="semu"/>
        <!-- template to get all arguments in argumentl -->

        <xsl:call-template name="proc_call_by_Argument">
            <xsl:with-param name="ids_string" select="@argumentl"/>
            <xsl:with-param name="semu" select="$semu"/>
        </xsl:call-template>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- (3.) Template that calls Arguments in argumnetl -->

    <xsl:template name="proc_call_by_Argument">
        <xsl:param name="semu"/>
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>

        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//Argument[@id = $ids_string]">
                    <xsl:with-param name="semu" select="$semu"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//Argument[@id = $id_str]">
                    <xsl:with-param name="semu" select="$semu"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_Argument">
                <xsl:with-param name="ids_string" select="$id_rest"/>
                <xsl:with-param name="semu" select="$semu"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Parole/ParoleSemant/Argument">
        <xsl:param name="semu"/>
        <xsl:choose>
            <xsl:when test="./@id = 'DummyArgument'"> </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#10;</xsl:text>

                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="substring(./@id,1,4)"/> <!-- OJO "substring(./@id,string-length(./@id) -3)" -->
                <xsl:text> a lemon:Argument .&#10;</xsl:text>
                
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text> </xsl:text>
                <xsl:text>parole:</xsl:text>
                <xsl:value-of select="@semanticrolel"/>
                <xsl:text> lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="substring(./@id,1,4)"/><!-- OJO "substring(./@id,string-length(./@id) -3)" -->
                <xsl:text> . &#10;</xsl:text>
                <xsl:if test="@informargl">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_</xsl:text>
                    <xsl:value-of select="substring(./@id,1,4)"/> <!-- OJO "substring(./@id,string-length(./@id) -3)" -->
                    
                    <xsl:choose>
                        <xsl:when test="substring(@informargl,1,14) = 'InfArgTemplate'">
                            <xsl:text> parole:template parole:</xsl:text>
                            <xsl:value-of select="substring(@informargl,7)"/>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        <xsl:when test="substring(@informargl,1,14) = 'InfArgTemplate'">
                            <xsl:text> parole:semanticClass parole:</xsl:text>
                            <xsl:value-of select="substring(@informargl,7)"/>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <!-- Catalan -->
                        
                        <xsl:when test="@informargl = 'INFARGN1'">
                            <xsl:text> parole:semanticClass parole:SemanticFeatreMEASURABLE</xsl:text>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="@informargl = 'INFARGN1'">
                            <xsl:text> parole:semanticClass parole:SemanticFeatreMEASURABLE</xsl:text>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="@informargl = 'INFARGN2'">
                            <xsl:text> parole:semanticClass parole:SemanticFeatreHUMAN</xsl:text>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="@informargl = 'INFARGN3'">
                            <xsl:text> parole:semanticClass parole:TmplAnimal</xsl:text>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="@informargl = 'INFARGN4'">
                            <xsl:text> parole:semanticClass parole:SemanticFeatreInstrument</xsl:text>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="@informargl = 'INFARGN5'">
                            <xsl:text> parole:semanticClass parole:SemanticFeatreEDIBLE</xsl:text>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="@informargl = 'INFARGN6'">
                            <xsl:text> parole:semanticClass parole:SemanticFeatreSEMIOTIC</xsl:text>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="@informargl = 'INFARGN7'">
                            <xsl:text> parole:semanticClass parole:SemanticFeatreLIQUID</xsl:text>
                            <xsl:text> . &#10;</xsl:text>
                        </xsl:when>
                        
                        <xsl:otherwise>
                           <xsl:text> parole:semanticFeature parole:</xsl:text>    
                            <xsl:value-of select="substring(@informargl,7)"/>
                            <xsl:text> . &#10;</xsl:text> 
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- End of argument (3) ################################################# -->

    <!-- ????? RDF -->
    <xsl:template name="fes_positions">
        <xsl:param name="semu"/>
        <xsl:apply-templates select="//SynU/CorrespSynUSemU[@targetsemu = $semu]" mode="x">
            <xsl:with-param name="semu" select="$semu"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ????? RDF -->
    <xsl:template match="Parole/ParoleSyntaxe/SynU/CorrespSynUSemU" mode="x">

        <xsl:choose>
            <xsl:when test="./@description">
                <xsl:call-template name="get_positions">
                    <xsl:with-param name="desc" select="./@description"/>
                    <xsl:with-param name="semu" select="./@targetsemu"/>
                    <xsl:with-param name="synu" select="../@id"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
                <xsl:call-template name="get_positions">
                    <xsl:with-param name="desc" select="../@description"/>
                    <xsl:with-param name="semu" select="./@targetsemu"/>
                    <xsl:with-param name="synu" select="../@id"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ????? RDF -->
    <xsl:template name="get_positions">
        <xsl:param name="desc"/>
        <xsl:param name="semu"/>
        <xsl:param name="synu"/>
        <xsl:apply-templates select="//Description[@id = $desc]" mode="get_position">
            <xsl:with-param name="semu" select="$semu"/>
            <xsl:with-param name="synu" select="$synu"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ????? RDF -->
    <xsl:template match="Parole/ParoleSyntaxe/Description" mode="get_position">
        <xsl:param name="semu"/>
        <xsl:param name="synu"/>
        <xsl:variable name="cons" select="@construction"/>
        <xsl:apply-templates select="//Construction[@id = $cons]" mode="get_position">
            <xsl:with-param name="semu" select="$semu"/>
            <xsl:with-param name="synu" select="$synu"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- ????? RDF -->
    <xsl:template match="Parole/ParoleSyntaxe/Construction" mode="get_position">
        <xsl:param name="semu"/>
        <xsl:param name="synu"/>
        <xsl:for-each select="./InstantiatedPositionC">
            <xsl:value-of select="$semu"/>
            <xsl:text> lemon:semArg parole:</xsl:text>
            <xsl:value-of select="$synu"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="../@id"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="@positionc"/>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>







    <!-- (4.) RDF builds the syntactic frame (for each description & descriptionl) ONLY VERBS!!!!!!!-->
    <xsl:template match="Parole/ParoleSyntaxe/SynU" mode="Frame">
        <xsl:if test="substring(@description,1,5) = 'DescV'"> <!-- OJO substring(@description,1,5) = 'DescV' cat: DV-->
            <xsl:for-each select="./CorrespSynUSemU">
                <xsl:variable name="semu" select="./@targetsemu"/>
                <xsl:choose>
                    <xsl:when test="./@description">
                        <xsl:text>lex:</xsl:text>
                        <xsl:value-of select="../@id"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="./@description"/>
                        <xsl:text> rdf:type owl:Thing ;  rdf:type lex:</xsl:text>
                        <xsl:value-of select="./@description"/>
                        <xsl:text> ;&#10;</xsl:text>

                        <xsl:variable name="id_str" select="@description"/>
                        <xsl:apply-templates select="//Description[@id = $id_str]">
                            <xsl:with-param name="synuID" select="../@id"/>
                            <xsl:with-param name="semu" select="$semu"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>lex:</xsl:text>
                        <xsl:value-of select="../@id"/>
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="../@description"/>
                        <xsl:text> rdf:type owl:Thing ;  rdf:type lex:</xsl:text>
                        <xsl:value-of select="../@description"/>
                        <xsl:text> ;&#10;</xsl:text>

                        <xsl:variable name="id_str" select="../@description"/>
                        <xsl:apply-templates select="//Description[@id = $id_str]">
                            <xsl:with-param name="synuID" select="../@id"/>
                            <xsl:with-param name="semu" select="$semu"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- frame(s) for @descritionl 
                <xsl:call-template name="proc_call_by_DescriptionlID">
                    <xsl:with-param name="ids_string" select="@descriptionl"/>
                    <xsl:with-param name="synuID" select="@id"/>
                    </xsl:call-template>-->
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <!-- (4.) RDF frame for Description -->
    <xsl:template match="Description">
        <xsl:param name="synuID"/>
        <xsl:param name="semu"/>
        <!--calls constrution template mode feats to get feats from Construction 
        <xsl:variable name="id_string" select="@construction"/>
        <xsl:apply-templates select="//Construction[@id=$id_string]" mode="feats"/> -->

        <!--calls construtionPositions to get positions -->

        <xsl:variable name="descriptionID" select="@id"/>
        <xsl:variable name="id_string" select="@construction"/>
        <xsl:apply-templates select="//Construction[@id=$id_string]" mode="positions">
            <xsl:with-param name="synuID" select="$synuID"/>
            <xsl:with-param name="descriptionID" select="$descriptionID"/>
            <xsl:with-param name="semu" select="$semu"/>
        </xsl:apply-templates>
        
    </xsl:template>

    <!-- (4.) RDF Construction template mode feats (gets syntlabel & SyntFeatureClosed/Open (not used) -->

    <xsl:template match="Description" mode="top"> 
        <xsl:if test="substring(@id,1,5) = 'DescV'"> <!-- OJO substring(@id,1,5) = 'DescV'  cat DV"-->
        <xsl:text>lex:</xsl:text><xsl:value-of select="@id"/><xsl:text> rdf:type owl:Class ; rdfs:subClassOf lexinfo:VerbFrame ;&#10;</xsl:text>
        
        <!-- OJO for Spanish 
        <xsl:text>&#9;dc:description "</xsl:text><xsl:value-of select="@naming"/><xsl:text>. </xsl:text>
        <xsl:value-of select="@example"/><xsl:text>. </xsl:text><xsl:value-of select="@self"/>
        <xsl:text>. (representative example: </xsl:text><xsl:value-of select="@representativemu"/><xsl:text>)" ;&#10;</xsl:text> -->
            
        <xsl:text>&#x9;dc:description "ex:</xsl:text>
        <xsl:value-of select="@example"/>
        <xsl:text>" ;&#10;</xsl:text>
        <xsl:text>&#9;dc:description "</xsl:text>
        <xsl:value-of select="@comment"/><xsl:text>. </xsl:text><xsl:value-of select="@self"/>
        <xsl:text>. (representative example: </xsl:text><xsl:value-of select="@representativemu"/><xsl:text>)"@cat ;&#10;</xsl:text>

            
            
        <xsl:variable name="id_string" select="@construction"/>
        <xsl:apply-templates select="//Construction[@id=$id_string]" mode="feats"/> 
        <xsl:text>.&#10;</xsl:text>
    </xsl:if>
    </xsl:template>
        
    <xsl:template match="Parole/ParoleSyntaxe/Construction" mode="feats">

        <xsl:for-each select="./SyntFeatureClosed">
            <xsl:call-template name="features"/>
        </xsl:for-each>
        <xsl:for-each select="./SyntFeatureOpen">
            <xsl:text>&#x9;parole:</xsl:text>
            <xsl:value-of select="@featurename"/>
            <xsl:text> "</xsl:text>
            <xsl:value-of select="@value"/>
            <xsl:text>" ;&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>


    <!-- (4.) RDF Construction template mode positions-->

    <xsl:template match="Parole/ParoleSyntaxe/Construction" mode="positions">
        <xsl:param name="synuID"/>
        <xsl:param name="descriptionID"/>
        <xsl:param name="semu"/>
        <!-- generates function relation -->
        <xsl:for-each select="./InstantiatedPositionC">
            <xsl:variable name="position" select="@positionc"/>
            <xsl:apply-templates select="//PositionC[@id=$position]"/>
            <xsl:text>lex:</xsl:text>
            <xsl:value-of select="$semu"/>
            <xsl:text>_ARG</xsl:text>
            <xsl:value-of select="position() -1"/> 
            <xsl:text>;&#10;</xsl:text> 
        </xsl:for-each> 
        <xsl:text>.&#10;</xsl:text>             
        <xsl:for-each select="./InstantiatedPositionC">
            <!-- marher -->
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 2) + 1) = 'EN'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "en" </xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 2) + 1) = 'DE'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "de" </xsl:text>
                <xsl:text>.</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 1) + 1) = 'A'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "a" </xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 3) + 1) = 'CON'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "con"</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 3) + 1) = 'POR'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "por"</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 4) + 1) = 'PARA'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "para"</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 6) + 1) = 'CONTRA'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "contra"</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 5) + 1) = 'HACIA'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "hacia"</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <!--
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 3) + 1) = 'AMB'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "amb"</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <xsl:if
                test="substring(@positionc, (string-length(@positionc) - 3) + 1) = 'PER'">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$semu"/>
                <xsl:text>_ARG</xsl:text>
                <xsl:value-of select="position() -1"/> 
                <xsl:text> lemon:marker "per"</xsl:text>
                <xsl:text> .</xsl:text>
                <xsl:text>&#10;</xsl:text>
            </xsl:if> -->
           <!-- constituent -->
            <xsl:choose>
                
                <!-- Català -->
                
                <!--
                <xsl:when test="substring(@positionc,1,6) = 'Ovpinf'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:VP </xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,6) = 'Svpinf'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:VP </xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,7) = 'PCvpinf'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:VP </xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,7) = 'CCvpinf'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:VP </xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,7) = 'CCvpger'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:VP ; lexinfo:verbFormMood lexinfo:gerundive</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,7) = 'CCclind'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:indicative</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,7) = 'CCclint'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,6) = 'Oclind'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:indicative</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,7) = 'Oclsubj'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:subjunctive</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,6) = 'Sclind'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:indicative</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,7) = 'Sclsubj'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:subjunctive</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,5) = 'Snppl'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:NP ; lexinfo:number lexinfo:plural</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,3) = 'Snp'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:NP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,5) = 'Onppl'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:NP ; lexinfo:number lexinfo:plural</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,3) = 'Onp'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:NP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,7) = 'PCclind'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:indicative</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                
                <xsl:when test="substring(@positionc,1,8) = 'PCclsubj'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:subjunctive</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,3) = 'PCn'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:PP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                -->
                
                
                
                
                
                
                
                
                
                
                
                <!-- Spanish: -->
                <xsl:when test="substring(@positionc,1,7) = 'Sujnppl'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:NP ; lexinfo:number lexinfo:plural</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="substring(@positionc,1,5) = 'Sujnp'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:NP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,8) = 'Sujclind'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:indicative</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,9) = 'Sujclsubj'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:subjunctive</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,8) = 'Sujvpinf'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:VP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,7) = 'Objnppl'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:NP ; lexinfo:number lexinfo:plural</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,5) = 'Objnp'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:NP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,8) = 'ObjClind'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:indicative</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,9) = 'ObjClsubj'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:subjunctive</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,5) = 'ObjCl'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,8) = 'ObjVpinf'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:VP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,4) = 'Pcnp'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:PP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,7) = 'Pcclind'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:indicative</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,8) = 'Pcclsubj'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause ; lexinfo:mood lexinfo:subjunctive</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,4) = 'Pccl'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:Clause</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                <xsl:when test="substring(@positionc,1,7) = 'Pcvpinf'">
                    <xsl:text>lex:</xsl:text>
                    <xsl:value-of select="$semu"/>
                    <xsl:text>_ARG</xsl:text>
                    <xsl:value-of select="position() -1"/> 
                    <xsl:text> lemon:constituent lex:PP</xsl:text>
                    <xsl:text> .</xsl:text>
                    <xsl:text>&#10;</xsl:text>
                </xsl:when>
                
            </xsl:choose>
            
        </xsl:for-each>
        
    </xsl:template>


    <!-- (4.) RDF looks for @function to create the corresponding property -->
    <xsl:template match="Parole/ParoleSyntaxe/PositionC">
        <xsl:choose>
            <xsl:when test="@function='SUBJECT'">
                <xsl:text>&#x9;lexinfo:subject </xsl:text>
            </xsl:when>
            <xsl:when test="@function='OBJECT'">
                <xsl:text>&#x9;lexinfo:directObject </xsl:text>
            </xsl:when>
            <xsl:when test="@function='INDIRECTOBJECT'">
                <xsl:text>&#x9;lexinfo:indirectObject </xsl:text>
            </xsl:when>
            <xsl:when test="@function='OBLIQUE'">
                <xsl:text>&#x9;lexinfo:adpositionalObject </xsl:text>
            </xsl:when>
            <xsl:when test="@function='PREPOBJ'">
                <xsl:text>&#x9;lexinfo:prepositionalObject </xsl:text>
            </xsl:when>
            <xsl:when test="@function='CLAUSCOMP'">
                <xsl:text>&#x9;lexinfo:sententialClause </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#x9;parole:</xsl:text>
                <xsl:value-of select="@function"/>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- (4.) RDF frame(s) for @descritionl -->
    <xsl:template name="proc_call_by_DescriptionlID">
        <xsl:param name="ids_string"/>
        <xsl:param name="synuID"/>

        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>
        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$synuID"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="$ids_string"/>
                <xsl:text> rdf:type owl:Thing ;  rdf:type lex:</xsl:text>
                <xsl:value-of select="$ids_string"/>
                <xsl:text> ;&#10;</xsl:text>

            </xsl:when>
            <xsl:otherwise>
                <xsl:text>lex:</xsl:text>
                <xsl:value-of select="$synuID"/>
                <xsl:text>_</xsl:text>
                <xsl:value-of select="$id_str"/>
                <xsl:text> rdf:type owl:Thing ;  rdf:type lex:</xsl:text>
                <xsl:value-of select="$id_str"/>
                <xsl:text> ;&#10;</xsl:text>

            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_DescriptionlID">
                <xsl:with-param name="ids_string" select="$id_rest"/>
                <xsl:with-param name="synuID" select="$synuID"/>

            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- End Frames #####################################################3-->







    <!-- RDF gets syntfeature closed/Open from Constructions -->
    <xsl:template match="Construction" mode="Top">
        <xsl:if test="./SyntFeatureClosed">
            <xsl:value-of select="@id"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="./SyntFeatureClosed/@featurename"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="./SyntFeatureClosed/@value"/>
            <xsl:text>;&#10;</xsl:text>
        </xsl:if>
        <xsl:if test="./SyntFeatureOpen">
            <xsl:value-of select="@id"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="./SyntFeatureOpen/@featurename"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="./SyntFeatureOpen/@value"/>
            <xsl:text>;&#10;</xsl:text>
        </xsl:if>

        <xsl:for-each select="./InstantiatedPositionC">
            <xsl:value-of select="../@id"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="./@range"/>
            <xsl:text> </xsl:text>
            <xsl:variable name="position" select="./@positionc"/>
            <xsl:apply-templates select="//PositionC[@id=$position]"/>
            <xsl:text>;&#10;</xsl:text>

        </xsl:for-each>
        <xsl:text>;&#10;</xsl:text>
    </xsl:template>





    <!-- general template that maps PAROLE attributes & SynFeatureClosed elements to lexinfo -->

    <xsl:template name="att2feats">
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="@*">
            <xsl:choose>
                <xsl:when test="name() = 'synulist'"/>
                <xsl:when test="name() = 'naming'"/>
                <xsl:when test="name() = 'autonomy'"/>
                <xsl:when test="name() = 'weightvalsemfeaturel'"/>
                <!-- PAROLE @naming="almívar"
                    example="Prunes en almívar"
                    comment="líquid"
                    freedefinition= -->
                <xsl:when test="name() = 'example'">
                    <xsl:text>&#x9;lemon:example [ lemon:value "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>" ] ;&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="name() = 'naming'">
                    <xsl:text>&#x9;rdfs:label "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"@cat ;&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="name() = 'comment'">
                    <xsl:text>&#x9;rdfs:comment "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"@cat ;&#10;</xsl:text>
                </xsl:when>
                
                <xsl:when test="name() = 'freedefinition'">
                    <xsl:text>&#x9;lemon:definition [ lemon:value "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>" ] ;&#10;</xsl:text>
                </xsl:when>
                <!-- PAROLE @gramcat & morphsubcat = lexinfo:partOfSpeech ; values are mapped when possible -->
                <xsl:when test=". = 'VERB'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:VerbPOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'NOUN'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:NounPOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'ADJECTIVE'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:AdjectivePOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'PRONOUN'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:PronounPOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'ADVERB'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:AdverbPOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'ADPOSITION'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:AdpositionPOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'CONJUNCTION'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:ConjunctionPOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'NUMERAL'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:NumeralPOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'DETERMINER'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:DeterminerPOS ;&#10;</xsl:text>
                </xsl:when>
                <xsl:when test=". = 'ARTICLE'">
                    <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:ArticlePOS ;&#10;</xsl:text>
                </xsl:when>


                <xsl:otherwise>
                    <xsl:text>&#x9;parole:</xsl:text>
                    <xsl:value-of select="name()"/>
                    <xsl:text> "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>" ;</xsl:text>

                    <xsl:text>&#10;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <!-- template that maps PAROLE SynFeatureClosed elements to lexinfo -->

    <xsl:template name="features">


        <xsl:choose>

            <!-- PAROLE @gramcat & morphsubcat = lexinfo:partOfSpeech ; values are mapped when possible -->
            <xsl:when test="./@value = 'VERB'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:VerbPOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'NOUN'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:NounPOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ADJECTIVE'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:AdjectivePOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'PRONOUN'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:PronounPOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ADVERB'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:AdverbPOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ADPOSITION'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:AdpositionPOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'CONJUNCTION'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:ConjunctionPOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'NUMERAL'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:NumeralPOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'DETERMINER'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:DeterminerPOS ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ARTICLE'">
                <xsl:text>&#x9;lexinfo:partOfSpeech lexinfo:ArticlePOS ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE VOICE = lexinfo:voice -->
            <xsl:when test="./@value = 'ACTIVE'">
                <xsl:text>&#x9;lexinfo:voice lexinfo:activeVoice ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'PASSIVE'">
                <xsl:text>&#x9;lexinfo:voice lexinfo:passiveVoice ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE ASPECT = lexinfo:aspect -->
            <xsl:when test="./@value = 'PERFECTIVE'">
                <xsl:text>&#x9;lexinfo:aspect lexinfo:perfective ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'IMPERFECTIVE'">
                <xsl:text>&#x9;lexinfo:aspect lexinfo:imperfective ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE FINITENESS = lexinfo:finiteness -->
            <xsl:when test="./@value = 'FINITE'">
                <xsl:text>&#x9;lexinfo:finiteness lexinfo:finite ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'NONFINITE'">
                <xsl:text>&#x9;lexinfo:finiteness lexinfo:nonFinite ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE TENSE = lexinfo:finiteness  (mapped values: PRESENT | IMPERFECT | FUTURE | PAST) not mapped: PLUSQUEPARFAIT-->
            <xsl:when test="./@value = 'PRESENT'">
                <xsl:text>&#x9;lexinfo:tense lexinfo:present ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'IMPERFECT'">
                <xsl:text>&#x9;lexinfo:tense lexinfo:imperfect ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'FUTURE'">
                <xsl:text>&#x9;lexinfo:tense lexinfo:future ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'PAST'">
                <xsl:text>&#x9;lexinfo:tense lexinfo:past ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE PERSON = lexinfo:person  (mapped values: 1 | 2 | 3) not mapped: 4 | NEG-->
            <xsl:when test="./@value = '1'">
                <xsl:text>&#x9;lexinfo:person lexinfo:firstPerson ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = '2'">
                <xsl:text>&#x9;lexinfo:person lexinfo:secondPerson ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = '3'">
                <xsl:text>&#x9;lexinfo:person lexinfo:thirdPerson ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE CASE = lexinfo:case  (mapped values: NOMINATIVE | GENITIVE | DATIVE | ACCUSATIVE | VOCATIVE | OBLIQUE | 
                    | PARTITIVE | INESSIVE | ELATIVE | ILLATIVE | ADESSIVE | ABLATIVE | ALLATIVE | ESSIVE | 
                    TRANSLATIVE | INSTRUCTIVE | ABESSIVE | COMITATIVE ) not mapped:   ORDINARY | OBJECT | REFL UNMARKED  PREPOSOBJ -->
            <xsl:when test="./@value = 'NOMINATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:nominativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'GENITIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:genitiveCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'DATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:dativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ACCUSATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:accusativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'VOCATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:vocativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'OBLIQUE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:obliqueCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'PARTITIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:partitiveCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'INESSIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:inessiveCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ELATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:elativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ILLATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:illativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ADESSIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:adessiveCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ABLATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:ablativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ALLATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:allativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ESSIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:essiveCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'TRANSLATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:translativeCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'INSTRUCTIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:instructiveCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'ABESSIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:abessiveCase ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'COMITATIVE'">
                <xsl:text>&#x9;lexinfo:case lexinfo:comitativeCase ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE GENDER = lexinfo:gender  (mapped values: MASCULINE | FEMININE | NEUTER | GCOMMON | 
                    not mapped: (MF |  CONT | INDISCRIMINATE | OO | INANIMATE | NONMASCULINE | NONNEUTER ) -->
            <xsl:when test="./@value = 'MASCULINE'">
                <xsl:text>&#x9;lexinfo:gender lexinfo:masculine ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'FEMININE'">
                <xsl:text>&#x9;lexinfo:gender lexinfo:feminine ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'NEUTER'">
                <xsl:text>&#x9;lexinfo:gender lexinfo:neuter ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'GCOMMON'">
                <xsl:text>&#x9;lexinfo:gender lexinfo:commonGender ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE TNUMBER = lexinfo:number  (mapped values: SINGULAR | PLURAL ; not mapped: INVARIANT -->
            <xsl:when test="./@value = 'SINGULAR'">
                <xsl:text>&#x9;lexinfo:number lexinfo:singular ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'PLURAL'">
                <xsl:text>&#x9;lexinfo:number lexinfo:plural ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE NDEGREE = lexinfo:degree  (mapped values: POSITIVE | COMPARATIVE | SUPERLATIVE ; not mapped: (ABSOLUTESUPERLATIVE | APPRECIATIVE | INTENSIVE ) -->
            <xsl:when test="./@value = 'POSITIVE'">
                <xsl:text>&#x9;lexinfo:degree lexinfo:positive ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'COMPARATIVE'">
                <xsl:text>&#x9;lexinfo:degree lexinfo:comparative ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'SUPERLATIVE'">
                <xsl:text>&#x9;lexinfo:degree lexinfo:superlative ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE DEFIN = lexinfo:definiteness  (mapped values: DEF | INDEF) -->
            <xsl:when test="./@value = 'DEF'">
                <xsl:text>&#x9;lexinfo:definiteness lexinfo:definite ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'INDEF'">
                <xsl:text>&#x9;lexinfo:definiteness lexinfo:indefinite ;&#10;</xsl:text>
            </xsl:when>
            <!-- PAROLE MOOD = lexinfo:mood OR lexinfo:VerbFormMood depending on value (not mapped : SUPINO | PRESPART | PASTPART | INFLECINF | CONJUNCTIVE -->
            <xsl:when test="./@value = 'INDICATIVE'">
                <xsl:text>&#x9;lexinfo:mood lexinfo:indicative ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'SUBJUNCTIVE'">
                <xsl:text>&#x9;lexinfo:mood lexinfo:subjunctive ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'IMPERATIVE'">
                <xsl:text>&#x9;lexinfo:mood lexinfo:imperative ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'GERUND'">
                <xsl:text>&#x9;lexinfo:verbFormMood lexinfo:gerundive ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'CONDITIONAL'">
                <xsl:text>&#x9;lexinfo:verbFormMood lexinfo:conditional ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'INFINITIVE'">
                <xsl:text>&#x9;lexinfo:verbFormMood lexinfo:infinitive ;&#10;</xsl:text>
            </xsl:when>
            <xsl:when test="./@value = 'PARTICIPLE'">
                <xsl:text>&#x9;lexinfo:verbFormMood lexinfo:participle ;&#10;</xsl:text>
            </xsl:when>

            <xsl:otherwise>
                <xsl:text>&#x9;parole:</xsl:text>
                <xsl:value-of select="./@featurename"/>
                <xsl:text> "</xsl:text>
                <xsl:value-of select="./@value"/>
                <xsl:text>" ;&#10;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>




</xsl:stylesheet>
