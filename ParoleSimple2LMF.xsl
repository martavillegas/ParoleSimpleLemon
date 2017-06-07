<?xml version="1.0" encoding="UTF-8"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"
        doctype-system="DTD_LMF_REV_16.dtd" doctype-public="LMF DTD"/>

    <!-- This ParoleSimple2LMF.xsl file takes as input a Parole/Simple lexicon and generates the corresponding 
        LMF version.
        
        version: 0.2
        date: February 2012
        Marta Villegas IULA UPF
        
        
        Important!!!:
        ==============
        
        a) xsl style sheets only work provided source file is well formed. Note that the original Parole SGML files may be not well formed
        (as this is understood in xml). So Parole sgml files need to be xml well formed, (with close tags, case sensitive ...)
        
        b) Sgml was case insensitive whereas xml is case-sensitive. Please check that all your elements/attributes are
        case sensitive as defined in the Parole dtd.
        
        c) As a general rule all Parole attributes become LMF feat nodes (*/@* -> ./feat) by means of the following rule:
        Y
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
            
            
            The removeAttributes.xsl is ment to remove 'irrelevant' id and IDREF(S) attributes in the LMF lexicons.
            run removeAttributes.xsl on LMF lexicon to get a 'cleaned' lexicon.
            
            d) Parole/Simple lexicons may have closure problems. This happens when an IDREF(S) attribute target(s) references an unknown ID.
            The resulting LMF lexicon inherits the closure problem.
	    This is particularly important when dealing with semantic relations: often in Parole/Simple lexicons, semantic relations imply 
	    defining 'dummy' target SemUs. To avoid validity errors, in some lexicons, dummy SemUs were created (without any link to syntactic and 		    
	    morpholigical layers). In Parole, this strategy is possible as MuS SynUs and SemUs are top elements. In LMF, SynUs and SemUs are not top 		    
	    elements but they are children of LexicalEntry. Thus having dummy SemUs is not possible.
            
            e) In Parole, the CorrespSynUSemU/@correspondence attribute is optional (implied) whereas the PredicativeRepresentation/@correspondences 
            LMF attribute is 'required'. Whenever a CorrespSynUSemU has no correspondence attribute the resulting PredicativeRepresentation will
            have an empty correspondence which fails to validate. Replace correspondences="" by correspondences="Dummy" and add the corresponding dummy
            SynSemCorrespondence node.
            
            
            
            
                     
            
            
        ParoleMorpho:
        =============
        
        - Parole MuS -> LexicalEntry, where:
            - all MuS attributes become feat elements (MuS/@* -> LexicalEntry/feat)
            - MuS/Gmu@inp becomes LexicalEntry@morphologicalPatterns
            - Gmu/Spelling becomes Lemma/feat@writtenForm
        - Parole GInP -> MorphologicalPattern. Notes:
            - This style sheet was created to convert the Spanish Parole lexicon into LMF. In the Spanish ParoleMorpho
              model (i) MuS collect the lemma plus the set of stems (if needed) and (ii) the paradigms collect the set of affixes
              to be added to the lemma or stem. This means that, InGInP elements Removal and
              AddedBefore are never used (they are allways empty). AddedAfter elements are used to add 'affixes' to relevant stems.
        - Parole CombMFCif -> TransformSet
        - Parole Cif -> Process. Notes:
            - if stemind = 0 and childs = 0 Then process/feat/att=operator val=addLemma
            - if stemind = 0 and Addafter Then process/feat/att=operator val= addLemma & process/feat/att=operator val=addAfter , att=stringValue val=affixstring
            - if stemind = N and child=0 Then process/feat/att=operator val= addStem , att=stemRank val= N
            - if stemind = N and AddAfter Then process/feat/att=operator val= addStem , att=stemRank val= N &  process/feat/att=operator val=addAfter && att=stringValue val=affixstring
            - Features from CombMF become feat in the corresponding MorphologicalPattern/TransformSet/GrammaticalFeatures node
            (CombMFCif/@combmf -> MorphologicalPattern/TransformSet/GrammaticalFeatures)
            In Parole, a CombMFCif refers to a CombTM (Combination of Morphological Features) via the
            'combmf' feature and to one or more Cif (calculation  of inflected form). The natural conversion to LMF is to
            map CombMFCif to TransformSet, combmf to TransformSet/GrammaticalFeatures and Cif to TransformSet/Process.
           Note that the Parole lexicon allows more than one Cif element for a given CombMFCif, when this happens we need to
           generate two TransformSet elements in order to distinguish between Processes:
           
           In this example, a unique CombMFCif element implies two TransformSet elements as we have two Cif (embedded) 
           elements. Nothe that each Cif element has its own transformation processes which cannot be grouped in the LMF
           model. Thus, we have to split the CombMFCif element into two TransformSets.
           
           <CombMFCif
           combmf="CQA2">
             <Cif
             range ="0"
             stemind ="1">
                <Removal></Removal>
                <AddedBefore></AddedBefore>
                <AddedAfter>os</AddedAfter>
             </Cif>
             <Cif
             range ="1"
             stemind ="1">
                <Removal></Removal>
                <AddedBefore></AddedBefore>
                <AddedAfter>s</AddedAfter>
             </Cif>
           </CombMFCif>
           
           
           <TransformSet>
           
            <Process>           
             <feat att="operator" val="addStem"/>           
             <feat att="stemRank" val="1"/>           
            </Process>
            
            <Process>           
             <feat att="operator" val="addAfter"/>           
             <feat att="stringValue" val="os"/>           
            </Process>
            
            <GrammaticalFeatures>                         
              <feat att="gender" val="MASCULINE"/>           
              <feat att="number" val="PLURAL"/>           
              <feat att="degree" val="POSITIVE"/>           
            </GrammaticalFeatures>
           
           </TransformSet>
            
            <TransformSet>
            
             <Process>            
                 <feat att="operator" val="addStem"/>            
                 <feat att="stemRank" val="1"/>            
             </Process>
             
             <Process>            
                 <feat att="operator" val="addAfter"/>            
                 <feat att="stringValue" val="s"/>            
             </Process>
             
             <GrammaticalFeatures>                 
              <feat att="gender" val="MASCULINE"/>            
              <feat att="number" val="PLURAL"/>            
              <feat att="degree" val="POSITIVE"/>   
             </GrammaticalFeatures>
         
         </TransformSet>
         
              
         
       ParoleSyntaxe:
       =============       
        - foreach SynU referenced in MuS/@synulist -> LexicalEntry/SyntacticBehaviour as follows:
        - For every, SynU, a corresponding SyntacticBehaviour is added where:
            - all SynU attributes become feat elements
            - @description & @descriptionl attribute become @subcategorizationFrames attribute
            - @framesetl attributes becomes @subcategorizationFrameSets attribute
            - SynU/CorrespSynUSemU/@targetsemu becomes SyntacticBehaviour/@senses attribute
            
        - For each Parole Description element, a corresponding SubcategorizationFrame element is created 
        as follows:
        
        1) Description/@ -> SubcategorizationFrame/feat: all Descriptiom attributes become feat 
        elements in SubcategorizationFrame
                 
        2) Construction/@* -> SubcategorizationFrame/feat: the ConstructionsFeats template gets the corresponding
        Construction attributes which also become feat elements in SubcategorizationFrame
                 
        3) Self/@ -> SubcategorizationFrame/LexemeProperty/feat : the Self template gets the corresponding 
        Self atributes which are included in the LexemeProperty child element. 
        Features from Self->IntervConst->syntagmacl are also included (SyntagmaT/@ -> SubcategorizationFrame/LexemeProperty/feat)
        
        The element 'IntervConst' is a 3-upple containing:
        a function:		       attribute 'function'
        a th-role:		        attribute 'throle'
        one/several sytagmat:	list syntagmatl
        
        This means that in the resulting LMF lexicon a given LexemeProperty may include features from different 
        SyntagmaTs. There is no way in LMF to clearly express this. thus in the example below a given IntervConst element 
        points to two SyntagmaT elements. Each SytagmaT is defined with a set of features. In the resulting 
        LexemeProperty element all features are listed together.
        
        
        <IntervConst
            id = "id"
            function ="function"
            th-role = "th-role"
            syntagmatl ="A B"/> ................ IDREF(s) pointing to relevant SyntagmaT below
            
        <SyntagmaT
            id="A"
            syntlabel="X">
            <SyntFeatureClosed
                featurename="f1"
                value="Y">
            </SyntFeatureClosed>
            <SyntFeatureClosed
                featurename="f2"
                value="Z">
            </SyntFeatureClosed>
        </SyntagmaT>
        
        <SyntagmaT
            id="B"
            syntlabel="q">
            <SyntFeatureClosed
                featurename="f1"
                 value="r">
            </SyntFeatureClosed>
            <SyntFeatureClosed
                featurename="f3"
                value="p">
            </SyntFeatureClosed>
        </SyntagmaT>
        
        <LexemeProperty>
            <feat att="intervconst" val="id"/>
            <feat att="id" val="ICV1"/>id
            <feat att="syntagmatl" val="A B"/>     .... list of syntagmats in the IntervConst/@syntagmatl element
            <feat att="id" val="A"/>  ................. info from syntagmat A:
            <feat att="syntlabel" val="X"/>
            <feat att="f1" val="Y"/>
            <feat att="f2" val="Z"/>
            <feat att="id" val="B"/>  ................. info from syntagmat B:
            <feat att="syntlabel" val="q"/>
            <feat att="f1" val="r"/>
            <feat att="f3" val="p"/>
        </LexemeProperty>
        
        Features from Self@syntagmat & Self@syntagmatl are not included (these are used to encode multiwords)

        4) Construction/InstantiatedPositionC - > SubcategorizationFrame/SyntacticArgument: the ConstructionPositions
        template gets the corresponding Positions which become SyntacticArguments where:
        
        PositionC/@ -> SubcategorizationFrame/SyntacticArgument/feat: all attributes in PositionC element become feat 
        elements in the SubcategorizationFrame/SyntacticArgument.
        
        PositionC/@syntagmacl -> SubcategorizationFrame/SyntacticArgument/feat: all attributes & features from syntagmas 
        (both SyntagmaT and SyntagmaNTC) in PositionC/@syntagmacl are collected as 
        SubcategorizationFrame/SyntacticArgument/feat elements. Again, there is no way to group in LMF features for each
        Syntagma. Thus we get:
        
        <PositionC
            id="Sujnp"
            function="SUBJECT"
            syntagmacl="NPany PROnom">
        </PositionC>
        
        <feat att="positionc" val="Sujnp"/>
        <feat att="id" val="Sujnp"/>
        <feat att="function" val="SUBJECT"/>
        <feat att="syntagmacl" val="NPany PROnom"/>  ....... list of syntagmas in PositionC/@syntagmacl
        <feat att="id" val="NPany"/> .......................  info coming from Syntagma NPany:
        <feat att="syntlabel" val="NP"/>
        <feat att="id" val="PROnom"/> ....................... info coming from Syntagma PROnom:
        <feat att="syntlabel" val="PRO"/>
        <feat att="MORPHSUBCAT" val="SSCSTRONG"/>
        <feat att="CASE" val="NOMINATIVE"/>
        
            
        - For each Parole FrameSet element, a corresponding SubcategorizationFrameSet element is created
  
        
        ParoleSemant:
        =============   
        - Information from Parole SynU/CorrespSynUSemU is added to corresponding LexicalEntry where:
        - For every SynU/CorrespSynUSemU@targetsemu a corresponding Sense is cretaed inside the LexicalEntry
        - SemU/@ -> Sense/feat : all SemU attributes become feat elements in the corresponding Sense element.
        - In addition:
        
        a) Semantic Features:
        
        SemU/@weightvalsemfeaturel -> Sense/feat, as follows:
    
        for each weightvalsemfeature in SemU/@weightvalsemfeaturel:
        we get the the corresponding ValSemFeature in the corresponding WeightValSemFeature/@valsemfeature 
        attribute and:
        
        ValSemFeature/@semfeature -> Sense/feat/@att
        ValSemFeature/@featurevalue OR ValSemFeature/@binaryvalue -> Sense/feat/@val
        
        For example:
        <SemU
        ...
        weightvalsemfeaturel = "WVSFTemplateUnitofmeasurementPROT"
        ...
        
        becomes
        
        <Sense id=...>
        ...
        <feat att="SFTemplate" val="Unitofmeasurement"/>
        ....
        
        (Parole model defines semantic features, whereas in LMF semantic features are not defined....)
        
        <WeightValSemFeature
        id="WVSFTemplateUnitofmeasurementPROT"
        weight="PROTOTYPICAL"
        comment="Abstract Template Type: WVSFTemplateUnitofmeasurement"
        valsemfeature="VSFTemplateUnitofmeasurement"/>
        
         <ValSemFeature
         id="VSFTemplateUnitofmeasurement"
         naming="VSFTemplateUnitofmeasurement"
         example="Template Type: TemplateTemplateUnitofmeasurement"
         comment="Abstract Template Type: TemplateTemplateUnitofmeasurement"
         multilingual="YES"
         featurevalue="Unitofmeasurement"  
         semfeature="SFTemplate"/>
         
    
    
    
        b) Predicates:
        
        SemU/Predicativerepresentation -> Sense/predicativeRepresentation as follows:
        Predicate -> SemanticPredicate
        Predicate/@argumentl -> SemanticPredicate/SemanticArgument
        SynU/CorrespSynUSemU -> Sense/PredicativeRepresentation/@correspondences
        Correspondence -> SynSemCorrespondence (no further analysis)
    
       c) Semantic Relations:
       
       SemU/RWeightValSemU -> Semse/SenseRelation where:
       SemU/RWeightValSemU/@* -> Semse/SenseRelation/feat
       SemU/RWeightValSemU/@target -> Semse/SenseRelation/@targets
       SemU/RWeightValSemU/@semr -> Semse/SenseRelation/feat/[@att=label val=" the naming of the corresponding RSemU if exists or id"]
       RSemU/@* -> Semse/SenseRelation/feat (not implemented)
       
       
        
    -->

    <xsl:template match="node()|@*">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>

    <xsl:strip-space elements="*"/>

    <xsl:template match="Parole">
        <LexicalResource dtdVersion="16">
            <GlobalInformation>
                <feat att="description"
                    val="This LexicalResource was generated by the ParoleSimple2LMF.xsl style sheet"
                />
            </GlobalInformation>
            <Lexicon>
                <xsl:text>&#10;&#10;</xsl:text>
                <xsl:comment> Lexical entries </xsl:comment>
                <xsl:text>&#10;&#10;</xsl:text>
                <xsl:apply-templates select="ParoleMorpho"/>
                <xsl:comment> Syntactic frames </xsl:comment>
                <xsl:text>&#10;&#10;</xsl:text>
                <xsl:apply-templates select="ParoleSyntaxe"/>
                <xsl:comment> Predicates and other semantic elements</xsl:comment>
                <xsl:text>&#10;&#10;</xsl:text>
                <xsl:apply-templates select="ParoleSemant/Predicate"/>
                <xsl:text>&#10;&#10;</xsl:text>
                <xsl:apply-templates select="ParoleSemant/Correspondence"/>
                <xsl:text>&#10;&#10;</xsl:text>
                <xsl:comment> Morphological Patterns </xsl:comment>
                <xsl:text>&#10;&#10;</xsl:text>
                <xsl:apply-templates select="ParoleMorpho/GInP"/>
                <xsl:text>&#10;&#10;</xsl:text>
            </Lexicon>
        </LexicalResource>
    </xsl:template>

    <!-- .................................Templates...................................................... -->

    <xsl:template match="ParoleMorpho">
        <xsl:apply-templates select="MuS"/>
    </xsl:template>

    <xsl:template match="ParoleSyntaxe">
        <xsl:apply-templates select="Description"/>
        <xsl:apply-templates select="FrameSet"/>
    </xsl:template>


    <!-- Templates for MuS conversion into LexicalEntry -->
    <xsl:template match="MuS">
        <LexicalEntry>
            <xsl:attribute name="id">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
            <xsl:attribute name="morphologicalPatterns">
                <xsl:value-of select="./Gmu/@inp"/>
            </xsl:attribute>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="att2feats"/>
            <Lemma>
                <xsl:text>&#10;</xsl:text>
                <feat>
                    <xsl:attribute name="att">
                        <xsl:text>writtenForm</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="val">
                        <xsl:value-of select="./Gmu/Spelling"/>
                    </xsl:attribute>
                </feat>
                <xsl:text>&#10;</xsl:text>
            </Lemma>
            <xsl:text>&#10;</xsl:text>
            <xsl:for-each select="./Gmu/GStem">
                <Stem>
                    <xsl:call-template name="att2feats"/>
                    <xsl:text>&#10;</xsl:text>
                    <feat>
                        <xsl:attribute name="att">
                            <xsl:text>writtenForm</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="val">
                            <xsl:value-of select="./Spelling"/>
                        </xsl:attribute>
                    </feat>
                    <xsl:text>&#10;</xsl:text>
                </Stem>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
            <!-- Semantics (Senses construction) -->
           <!-- <xsl:variable name="has_ids" select="@synulist"/> -->
            <xsl:call-template name="proc_call_by_SemUid">
                <xsl:with-param name="ids_string" select="@synulist"/>
            </xsl:call-template>
            <!-- Syntax (SyntacticBehaviour construction) -->
            <xsl:call-template name="proc_call_by_id">
                <xsl:with-param name="ids_string" select="@synulist"/>
            </xsl:call-template>
        </LexicalEntry>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <!-- Template that looks for the set of SemUs in CorrespSynUSemU/@targetsemu. 
        it calls the SemU Template that builds the Sense part of the LexicalEntry -->

    <xsl:template name="proc_call_by_SemUid">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>
        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//SynU[@id = $ids_string]/CorrespSynUSemU"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//SynU[@id = $id_str]/CorrespSynUSemU"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_SemUid">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Semantics: gets SemU id, looks for SemU element and builds the corresponding LMF Sense node -->

    <xsl:template match="CorrespSynUSemU">
        <xsl:variable name="has_id" select="@targetsemu"/>
        <!-- checks if 'targetsemu' was already referenced by preceeding CorrespSynUSemU to avoid duplicates -->
        <xsl:if test="not (preceding::CorrespSynUSemU[@targetsemu=$has_id])">
            <xsl:call-template name="call_SemU">
                <xsl:with-param name="id_string" select="@targetsemu"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="call_SemU">
        <xsl:param name="id_string"/>
        <xsl:apply-templates select="//SemU[@id=$id_string]"> </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Parole/ParoleSemant/SemU">
        <xsl:apply-templates select="." mode="print_value"/>
        <Sense>
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="att2feats"/>
            <!-- template to get all WeightValSemFeatures -->
            <!-- <xsl:variable name="has_ids" select="@weightvalsemfeaturel"/> -->
            <xsl:call-template name="proc_call_by_WeightValSemFeatureid">
                <xsl:with-param name="ids_string" select="@weightvalsemfeaturel"/>
            </xsl:call-template>
            <!-- template to get PredicativeRepresentation -->
            <xsl:if test="./PredicativeRepresentation">
                <PredicativeRepresentation>
                    <xsl:attribute name="predicate">
                        <xsl:value-of select="./PredicativeRepresentation/@predicate"/>
                    </xsl:attribute>
                    <xsl:attribute name="correspondences">
                        <!-- looks for correspondences in  /Parole/ParoleSyntaxe/SynU/CorrespSynUSemU[@targetsemu = id] -->
                        <xsl:call-template name="call_Correspondences">
                            <xsl:with-param name="targetsemu" select="@id"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:text>&#10;</xsl:text>
                    <xsl:for-each select="./PredicativeRepresentation/@*">
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
                </PredicativeRepresentation>
                <xsl:text>&#10;</xsl:text>
            </xsl:if>
            <!-- RWeightValSemU -->
            <xsl:for-each select="./RWeightValSemU">
                <SenseRelation>
                    <xsl:attribute name="targets">
                        <xsl:value-of select="@target"/>
                    </xsl:attribute>
                    <!-- looks for relevant RSemUs  -->
                    <xsl:call-template name="call_RSemU">
                        <xsl:with-param name="semr" select="@semr"/>
                    </xsl:call-template>
                    <xsl:text>&#10;</xsl:text>
                    <xsl:call-template name="att2feats"/>
                </SenseRelation>
                <xsl:text>&#10;</xsl:text>
            </xsl:for-each>
        </Sense>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- Template that looks for the set of WeightValSemFeature in weightvalsemfeaturel. 
        it calls the  -->

    <xsl:template name="proc_call_by_WeightValSemFeatureid">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>

        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//WeightValSemFeature[@id = $ids_string]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//WeightValSemFeature[@id = $id_str]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_WeightValSemFeatureid">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- WeightValSemFeature ValSemFeature -->

    <xsl:template match="Parole/ParoleSemant/WeightValSemFeature">
        <xsl:call-template name="call_ValSemFeature">
            <xsl:with-param name="id_string" select="@valsemfeature"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="call_ValSemFeature">
        <xsl:param name="id_string"/>
        <xsl:apply-templates select="//ValSemFeature[@id=$id_string]"> </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Parole/ParoleSemant/ValSemFeature">
        <feat>
            <xsl:attribute name="att">
                <xsl:value-of select="@semfeature"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="@featurevalue">
                    <xsl:attribute name="val">
                        <xsl:value-of select="@featurevalue"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="val">
                        <xsl:value-of select="@binaryvalue"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </feat>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <!-- Predicate -->

    <xsl:template match="Parole/ParoleSemant/Predicate">
        <SemanticPredicate>
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="att2feats"/>
            <!-- template to get all WeightValSemFeatures -->
            <!--<xsl:variable name="has_ids" select="@weightvalsemfeaturel"/>-->
            <xsl:call-template name="proc_call_by_WeightValSemFeatureid">
                <xsl:with-param name="ids_string" select="@weightvalsemfeaturel"/>
            </xsl:call-template>
            <!-- template to get all arguments in argumentl -->
            <xsl:variable name="has_ida" select="@argumentl"/>
            <xsl:call-template name="proc_call_by_Argument">
                <xsl:with-param name="ids_string" select="@argumentl"/>
            </xsl:call-template>
            <xsl:text>&#10;</xsl:text>
        </SemanticPredicate>
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
        <SemanticArgument>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="att2feats"/>
            <!-- template to get all InformArg in informargl -->
            <xsl:variable name="has_ida" select="@informargl"/>
            <xsl:call-template name="proc_call_by_InformArg">
                <xsl:with-param name="ids_string" select="@informargl"/>
            </xsl:call-template>
        </SemanticArgument>
    </xsl:template>

    <!-- Template that calls InformArg in informargl -->

    <xsl:template name="proc_call_by_InformArg">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>

        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//InformArg[@id = $ids_string]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//InformArg[@id = $id_str]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_InformArg">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Parole/ParoleSemant/InformArg">
        <xsl:call-template name="att2feats"/>
        <!-- template to get all WeightValSemFeatures -->
        <!-- <xsl:variable name="has_ids" select="@weightvalsemfeaturel"/>-->
        <xsl:call-template name="proc_call_by_WeightValSemFeatureid">
            <xsl:with-param name="ids_string" select="@weightvalsemfeaturel"/>
        </xsl:call-template>
    </xsl:template>


    <!-- Correspondence -->

    <xsl:template match="Parole/ParoleSemant/Correspondence">
        <SynSemCorrespondence>
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:call-template name="att2feats"/>
        </SynSemCorrespondence>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- Template that looks for correspondences -->

    <xsl:template name="call_Correspondences">
        <xsl:param name="targetsemu"/>
        <xsl:for-each select="/Parole/ParoleSyntaxe/SynU/CorrespSynUSemU[@targetsemu = $targetsemu]">
            <xsl:if test="@correspondence">
                <xsl:value-of select="@correspondence"/>
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Template that looks for RSemU -->

    <xsl:template name="call_RSemU">
        <xsl:param name="semr"/>
        <xsl:apply-templates select="//RSemU[@id=$semr]"/>
    </xsl:template>

    <xsl:template match="Parole/ParoleSemant/RSemU">
        <!-- use naming if exists to name the semantic relation, otherwise use ID -->
        <feat>
            <xsl:attribute name="att">
                <xsl:text>label</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="val">
                <xsl:choose>
                    <xsl:when test="@naming">
                        <xsl:value-of select="@naming"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </feat>
    </xsl:template>

    <!-- Template that looks for the set of SynUs in synulist. 
    it calls the SynU Template that builds the SyntacticBehaviour part of the LExicalEntry -->

    <xsl:template name="proc_call_by_id">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>

        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//SynU[@id = $ids_string]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//SynU[@id = $id_str]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_id">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template match="Parole/ParoleSyntaxe/SynU">
        <xsl:apply-templates select="." mode="print_value"/>
        <SyntacticBehaviour>
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:if test="./CorrespSynUSemU">
                <xsl:attribute name="senses">
                    <xsl:for-each select="./CorrespSynUSemU">
                        <xsl:variable name="has_id" select="@targetsemu"/>
                        <xsl:if test="not (preceding-sibling::CorrespSynUSemU[@targetsemu=$has_id])">
                            <xsl:value-of select="@targetsemu"/>
                        </xsl:if>
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="subcategorizationFrames">
                <xsl:value-of select="@description"/>
                <xsl:if test="@descriptionl">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="@descriptionl"/>
                </xsl:if>
            </xsl:attribute>
            <xsl:if test="@subcategorizationFrameSets">
                <xsl:attribute name="subcategorizationFrameSets">
                    <xsl:value-of select="@framesetl"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="att2feats"/>
        </SyntacticBehaviour>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>



    <!-- Templates for SubcategorizationFrame and SubcategorizationFrameSet (Parole Description & FrameSet)  -->


    <xsl:template match="Description">
        <SubcategorizationFrame>
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="att2feats"/>
            <!--calls constrution template mode feats -->
            <xsl:call-template name="call_ConstructionFeats">
                <xsl:with-param name="id_string" select="@construction"/>
            </xsl:call-template>
            <!--calls Self template-->
            <xsl:call-template name="call_Self">
                <xsl:with-param name="id_string" select="@self"/>
            </xsl:call-template>
            <!--calls constrution template mode positions-->
            <xsl:call-template name="call_ConstructionPositions">
                <xsl:with-param name="id_string" select="@construction"/>
            </xsl:call-template>
        </SubcategorizationFrame>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- Construction template mode feats-->
    <xsl:template name="call_ConstructionFeats">
        <xsl:param name="id_string"/>
        <xsl:apply-templates select="//Construction[@id=$id_string]" mode="feats"
        > </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Parole/ParoleSyntaxe/Construction" mode="feats">
        <xsl:call-template name="att2feats"/>
        <xsl:for-each select="./SyntFeatureClosed">
            <feat>
                <xsl:attribute name="att">
                    <xsl:value-of select="@featurename"/>
                </xsl:attribute>
                <xsl:attribute name="val">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </feat>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="./SyntFeatureOpen">
            <feat>
                <xsl:attribute name="att">
                    <xsl:value-of select="@featurename"/>
                </xsl:attribute>
                <xsl:attribute name="val">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </feat>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>


    <!-- Construction template mode positions-->
    <xsl:template name="call_ConstructionPositions">
        <xsl:param name="id_string"/>
        <xsl:apply-templates select="//Construction[@id=$id_string]" mode="positions"
        > </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Parole/ParoleSyntaxe/Construction" mode="positions">
        <xsl:for-each select="./InstantiatedPositionC">
            <SyntacticArgument>
                <xsl:text>&#10;</xsl:text>
                <xsl:call-template name="att2feats"/>
                <!--calls Position template-->
                <xsl:call-template name="call_Position">
                    <xsl:with-param name="id_string" select="@positionc"/>
                </xsl:call-template>
            </SyntacticArgument>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>


    <!-- Position template -->
    <xsl:template name="call_Position">
        <xsl:param name="id_string"/>
        <xsl:apply-templates select="//PositionC[@id=$id_string]"> </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Parole/ParoleSyntaxe/PositionC">
        <xsl:call-template name="att2feats"/>
        <!--calls SyntagmaNTC & (or) template-->
        <xsl:call-template name="proc_call_by_id_SyntagmaNTC">
            <xsl:with-param name="ids_string" select="@syntagmacl"/>
        </xsl:call-template>
        <xsl:call-template name="proc_call_by_id_SyntagmaT">
            <xsl:with-param name="ids_string" select="@syntagmacl"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="proc_call_by_id_SyntagmaNTC">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>
        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//SyntagmaNTC[@id = $ids_string]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//SyntagmaNTC[@id = $id_str]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_id_SyntagmaNTC">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template match="Parole/ParoleSyntaxe/SyntagmaNTC">
        <xsl:call-template name="att2feats"/>
        <xsl:for-each select="./SyntFeatureClosed">
            <feat>
                <xsl:attribute name="att">
                    <xsl:value-of select="@featurename"/>
                </xsl:attribute>
                <xsl:attribute name="val">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </feat>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="./SyntFeatureOpen">
            <feat>
                <xsl:attribute name="att">
                    <xsl:value-of select="@featurename"/>
                </xsl:attribute>
                <xsl:attribute name="val">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </feat>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>



    <!-- Self template -->
    <xsl:template name="call_Self">
        <xsl:param name="id_string"/>
        <xsl:apply-templates select="//Self[@id=$id_string]"> </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Parole/ParoleSyntaxe/Self">
        <LexemeProperty>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="att2feats"/>
            <!--calls IntervConst template-->
            <xsl:call-template name="call_IntervConst">
                <xsl:with-param name="id_string" select="@intervconst"/>
            </xsl:call-template>
        </LexemeProperty>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- IntervConst template -->
    <xsl:template name="call_IntervConst">
        <xsl:param name="id_string"/>
        <xsl:apply-templates select="//IntervConst[@id=$id_string]"> </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Parole/ParoleSyntaxe/IntervConst">
        <xsl:call-template name="att2feats"/>
        <!--calls SyntagmaT template-->
        <xsl:call-template name="proc_call_by_id_SyntagmaT">
            <xsl:with-param name="ids_string" select="@syntagmatl"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="proc_call_by_id_SyntagmaT">
        <xsl:param name="ids_string"/>
        <xsl:variable name="id_str" select="normalize-space(substring-before($ids_string, ' '))"/>
        <xsl:variable name="id_rest" select="substring-after($ids_string, ' ')"/>
        <xsl:choose>
            <xsl:when test="string-length($id_str) = 0 and string-length($ids_string) &gt; 0">
                <xsl:apply-templates select="//SyntagmaT[@id = $ids_string]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//SyntagmaT[@id = $id_str]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="string-length($id_rest) &gt; 0">
            <xsl:call-template name="proc_call_by_id_SyntagmaT">
                <xsl:with-param name="ids_string" select="$id_rest"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template match="Parole/ParoleSyntaxe/SyntagmaT">
        <xsl:call-template name="att2feats"/>
        <xsl:for-each select="./SyntFeatureClosed">
            <feat>
                <xsl:attribute name="att">
                    <xsl:value-of select="@featurename"/>
                </xsl:attribute>
                <xsl:attribute name="val">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </feat>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="./SyntFeatureOpen">
            <feat>
                <xsl:attribute name="att">
                    <xsl:value-of select="@featurename"/>
                </xsl:attribute>
                <xsl:attribute name="val">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </feat>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <!-- Frameset emplate -->
    <xsl:template match="Parole/ParoleSyntaxe/FrameSet">
        <SubcategorizationFrameSet>
            <xsl:attribute name="id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:attribute name="subcategorizationFrames">
                <xsl:value-of select="@descriptionl"/>
            </xsl:attribute>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="att2feats"/>
        </SubcategorizationFrameSet>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- Templates for GInP conversion into MorphologicalPattern  -->


    <xsl:template match="GInP">
        <MorphologicalPattern>
            <xsl:attribute name="id">
                <xsl:value-of select="./@id"/>
            </xsl:attribute>
            <xsl:text>&#10;</xsl:text>
            <feat>
                <xsl:attribute name="att">
                    <xsl:text>example</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="val">
                    <xsl:value-of select="./@example"/>
                </xsl:attribute>
            </feat>
            <xsl:text>&#10;</xsl:text>
            <xsl:apply-templates select="CombMFCif"/>
        </MorphologicalPattern>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <xsl:template match="CombMFCif">
        <xsl:apply-templates select="Cif"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>



    <!-- CombMF template -->
    <xsl:template name="call_CombMF">
        <xsl:param name="id_string"/>
        <xsl:apply-templates select="//CombMF[@id=$id_string]"> </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="Parole/ParoleMorpho/CombMF">
        <xsl:call-template name="att2feats"/>
    </xsl:template>

    <xsl:template match="Cif">
        <TransformSet>
            <xsl:text>&#10;</xsl:text>
            <!-- when operating on lemma (stemind="0") -->
            <xsl:if test="./@stemind = '0'">
                <!-- when no affix added (AddedAfter = null) -->
                <xsl:choose>
                    <xsl:when test="./AddedAfter = ''">
                        <Process>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>operator</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:text>addLemma</xsl:text>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                        </Process>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:when>
                    <!-- when adding affix (AddedAfter not null) -->
                    <xsl:otherwise>
                        <Process>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>operator</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:text>addLemma</xsl:text>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                        </Process>
                        <xsl:text>&#10;</xsl:text>
                        <Process>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>operator</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:text>addAfter</xsl:text>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>stringValue</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:value-of select="./AddedAfter"/>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                        </Process>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <!-- when operating on stem (stemind >"0") ....................................-->
            <xsl:if test="./@stemind > '0'">
                <!-- when no affix added (AddedAfter = null) -->
                <xsl:choose>
                    <xsl:when test="./AddedAfter = ''">
                        <Process>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>operator</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:text>addStem</xsl:text>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>stemRank</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:value-of select="./@stemind"/>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                        </Process>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:when>
                    <!-- when adding affix (AddedAfter not null) -->
                    <xsl:otherwise>
                        <Process>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>operator</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:text>addStem</xsl:text>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>stemRank</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:value-of select="./@stemind"/>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                        </Process>
                        <xsl:text>&#10;</xsl:text>
                        <Process>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>operator</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:text>addAfter</xsl:text>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                            <feat>
                                <xsl:attribute name="att">
                                    <xsl:text>stringValue</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="val">
                                    <xsl:value-of select="./AddedAfter"/>
                                </xsl:attribute>
                            </feat>
                            <xsl:text>&#10;</xsl:text>
                        </Process>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <GrammaticalFeatures>
                <xsl:text>&#10;</xsl:text>
                <xsl:call-template name="call_CombMF">
                    <xsl:with-param name="id_string" select="../@combmf"/>
                </xsl:call-template>
            </GrammaticalFeatures>
            <xsl:text>&#10;</xsl:text>
        </TransformSet>
        <xsl:text>&#10;</xsl:text>
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
