-- Vaatz 부품개발_EO 배포현황

/* 작성자 : 이소진
 * 작업내역 : 2025.06.09 최초 작성
 * 
 * DB Connection : LEGERCY_VER
 * 
 * [Target/Source 앱]
 * Vaatz_변경적재(부품개발)
 * Vaatz_초기적재(부품개발)_Ext
 * Vaatz_변경적재(마스터外)_NEW2
 * 
 * [Table - EXTERNALDB(XXEBOM)]
 * TABLE1
 * TABLE2
 * TABLE3
 * TABLE4
 * TABLE5
 * 
 * [Table]
 * TABLE6		EO정보 마스터
 * TABLE7		EO부품정보 마스터
 * TABLE8		EO배포 팀지정 (개발부품정보)
 * TABLE9		EO배포 구매담당지정 (구매담당자정보)
 * TABLE10		부품별업체지정 마스터
 * TABLE11		개발요청서번호정보
 * TABLE12		EO-부품 협력사배포 이력정보
 * TABLE13		부품정보 마스터
 * TABLE14		*업체마스터
 * TABLE15		상세코드마스터
 *  
 * */

WITH SYCODE AS (
	SELECT /*+ MATERIALIZE */ 
		  CDCL_ID
		, NVL(TRIM(CD_NM_ENG),' ') AS CD_NM_ENG
	FROM XXEBOM.TABLE1@EXTERNALDB
	),
SYCDCL AS (
	SELECT /*+ MATERIALIZE */ 
		  CDCL_ID
		, UP_CDCL_ID
		, NVL(TRIM(CDCL_NM),' ') AS CDCL_NM
	FROM XXEBOM.TABLE2@EXTERNALDB
	),
EPT AS (
	SELECT /*+ MATERIALIZE */ 
		  EONO
		, MIN(OD06_OPEI_C) AS EPT
	FROM XXEBOM.TABLE3@EXTERNALDB
	WHERE OD06_OPEI_C >  ' '
	GROUP BY EONO
	),
QQ_Tmp AS (
	SELECT /*+ MATERIALIZE */ 
		  Q1.OD03_RPNO_C		-- ORG PART NO
		, TRIM(Q1.OD03_RRMK_C) AS CDCL_ID
		, Q1.EONO
	FROM (
		SELECT /*+ MATERIALIZE */  * FROM XXEBOM.TABLE4@EXTERNALDB WHERE OD03_RCID_C = 'C' 
		UNION ALL 
		SELECT /*+ MATERIALIZE */  * FROM XXEBOM.TABLE4@EXTERNALDB WHERE OD03_RCID_C <> 'C' AND OD03_RRBM_C <> 'D'	-- OD03_RCID_C = 'C' OR OD03_RRBM_C <> 'D'를 UNION ALL로 변환 시 'C' 중복제거
		) Q1
	INNER JOIN XXEBOM.TABLE5@EXTERNALDB Q2
	ON Q1.EONO = Q2.EONO
	)
/**********************************************************************************************
	Fact
**********************************************************************************************/
SELECT
	  SO.VAAT_CO_CD
	, SO.PUR_CHRG_DCD
	, SO.PUR_CRGR_ID
	, SO.X10_EO_NO AS EO_NO
	, SO.EO_WDT_YMD
	, SO."ProcDate"
	, SO.RQ_YMD
	, SO.FIN_MDFY_YMD
	, NVL(SO.PCE_ALTR_YN,'') AS PCE_ALTR_YN
	, SO.A15_VPNO AS VPNO
	, SO.COF_CD
	, SO.EPT
	, PART.PART_NM
	, QQ.COMD_RRMK_C AS ZREASON
	, SUBSTR(SO.A15_VPNO,1,3) AS VPNO3    
	, SUBSTR(SO.A15_VPNO,1,5) AS VPNO5   
	, SUBSTR(SO.X10_EO_NO,1,3) AS EO_NO3
	, 1 AS SUM_CNT
FROM (
	SELECT 
		  X.EO_NO
		, X.X9_EO_NO
		, X.X10_EO_NO
		, X.EO_WDT_YMD
		, X."ProcDate"
		, X.RQ_YMD
		, X.FIN_MDFY_YMD
		, Y.VPNO
		, Y.PCE_ALTR_YN
		, A.VAAT_CO_CD
		, A.PUR_CHRG_DCD
		, A.A15_VPNO
		, B.PUR_CRGR_ID
		, C.COF_CD
		, C.DVLP_RQ_NO
		, Z.EPT
	FROM (
	--------------------------- X 시작 ------------------------;
		SELECT /*+ INDEX(T TABLE6_IDX2) */
			  EO_NO
			, TRIM(EO_NO) || RPAD(' ', 9-LENGTH(TRIM(EO_NO))) AS X9_EO_NO
			, TRIM(EO_NO) || RPAD(' ', 10-LENGTH(TRIM(EO_NO))) AS X10_EO_NO
			, TO_DATE(EO_WDT_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS EO_WDT_YMD		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
			, TO_DATE(EO_WDT_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
			, CURRENT_DATE + INTERVAL '9' HOUR AS RQ_YMD							-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
			, CURRENT_DATE + INTERVAL '9' HOUR AS FIN_MDFY_YMD						-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		FROM VPDMADM.TABLE6 T	/* EO정보 마스터 */
		WHERE EO_WDT_YMD
			BETWEEN '20200101' AND '20200131'
--			BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -60),'YYYYMMDD') 	-- 최근 5년
--				AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR,'YYYYMMDD')
		) X
	--------------------------- Y 시작 ------------------------;
	INNER JOIN (
		SELECT /*+ INDEX(T TABLE7_PK) */
			  EO_NO
			, VPNO
			, PCE_ALTR_YN
		FROM VPDMADM.TABLE7 T	/* EO부품정보 마스터 */
		) Y
	ON X.EO_NO = Y.EO_NO
	--------------------------- A 시작 ------------------------;
	INNER JOIN (
		SELECT /*+ INDEX(T TABLE8_PK) */
			  VAAT_CO_CD
			, PUR_CHRG_DCD
			, VPNO
			, TRIM(VPNO) || RPAD(' ', 15-LENGTH(TRIM(VPNO))) AS A15_VPNO
		FROM VPDMADM.TABLE8 T	/* EO배포 팀지정 (개발부품정보) */
		) A
	ON Y.VPNO = A.VPNO
	--------------------------- B 시작 ------------------------;
	INNER JOIN (
		SELECT /*+ INDEX(T TABLE9_IDX99) */
			  VAAT_CO_CD
			, PUR_CHRG_DCD
			, VPNO
			, PUR_CRGR_ID
		FROM VPDMADM.TABLE9 T	/* EO배포 구매담당지정 (구매담당자정보) */
		) B
	ON  A.VPNO 			= B.VPNO 
	AND A.PUR_CHRG_DCD 	= B.PUR_CHRG_DCD
	AND A.VAAT_CO_CD	= B.VAAT_CO_CD
	--------------------------- C 시작 ------------------------;
	INNER JOIN ( 
		SELECT /*+ INDEX(T TABLE10_IDX3) */
			  VAAT_CO_CD
			, PUR_CHRG_DCD
			, VPNO		
			, PUR_CRGR_ID
			, TRIM(COF_CD) AS COF_CD
			, DVLP_RQ_NO 
		FROM VPDMADM.TABLE10 T	/* 부품별업체지정 마스터 */
		) C
	ON  B.VAAT_CO_CD 	= C.VAAT_CO_CD
	AND B.PUR_CHRG_DCD 	= C.PUR_CHRG_DCD
	AND B.VPNO			= C.VPNO
	AND B.PUR_CRGR_ID	= C.PUR_CRGR_ID
	--------------------------- D 시작 ------------------------;
	INNER JOIN VPDMADM.TABLE11 D	/* 개발요청서번호정보 */ 
	ON C.DVLP_RQ_NO = D.DVLP_RQ_NO
	--------------------------- E 시작 ------------------------;
	INNER JOIN (
		SELECT /*+ INDEX(T TABLE12_PK) */
			  DVLP_RQ_NO
			, VPNO
			, EO_NO
		FROM VPDMADM.TABLE12 T	/* EO-부품 협력사배포 이력정보 */
		WHERE 1=1
			AND FIRM_INFM_YMD IS NOT NULL
			AND EO_NO IS NOT NULL
		) E
	ON  D.DVLP_RQ_NO	= E.DVLP_RQ_NO
	AND C.VPNO			= E.VPNO
	AND Y.EO_NO 		= E.EO_NO
	--------------------------- P 시작 ------------------------;
	INNER JOIN VPDMADM.TABLE13 P	/* 부품정보 마스터 */
	ON E.VPNO = P.VPNO
	--------------------------- Z 시작 ------------------------;
	LEFT JOIN ( SELECT EONO AS X9_EO_NO, EPT FROM EPT ) Z
	ON X.X9_EO_NO = Z.X9_EO_NO
	) SO
INNER JOIN (
	SELECT /*+ INDEX(T TABLE13_PK) */
		  TRIM(VPNO) || RPAD(' ', 15-LENGTH(TRIM(VPNO))) AS VPNO
		, PART_NM
	FROM VPDMADM.TABLE13 T
	) PART
ON SO.A15_VPNO = PART.VPNO
LEFT JOIN (
	SELECT 
		  TRIM(QQ_Tmp.EONO) || RPAD(' ', 10-LENGTH(TRIM(QQ_Tmp.EONO))) AS X10_EO_NO
		, TRIM(QQ_Tmp.OD03_RPNO_C) || RPAD(' ', 15-LENGTH(TRIM(QQ_Tmp.OD03_RPNO_C))) AS A15_VPNO
		, QQ_Tmp.CDCL_ID
		, COMD_RRMK_C.COMD_RRMK_C
	FROM QQ_Tmp
	-------------------- COMD_RRMK_C_Tmp 시작 -----------------;
	LEFT JOIN (
		SELECT 
			  COMD_RRMK_C_Tmp.CDCL_ID
			, COMD_RRMK_C_Tmp."A.CD_NM_ENG"
			, COMD_RRMK_C_Tmp."B.UP_CDCL_ID"
			, COMD_RRMK_C_Tmp."B.CDCL_NM"
			, SYCDCL1.UP_CDCL_ID
			, SYCDCL2.CDCL_NM
			, CD_NM_ENG.CD_NM_ENG
			---------------------- COMD_RRMK_C 시작 -------------------;
			, COMD_RRMK_C_Tmp.CDCL_ID || ' ' || ( CASE WHEN SYCDCL1.UP_CDCL_ID IN ('EORQ','LR','WD') THEN '' ELSE SYCDCL2.CDCL_NM || '-' END )   || COMD_RRMK_C_Tmp."B.CDCL_NM" AS COMD_RRMK_C
		/*	, CASE WHEN 
			  COMD_RRMK_C_Tmp.CDCL_ID || ' ' || ( CASE WHEN SYCDCL1.UP_CDCL_ID IN ('EORQ','LR','WD') THEN '' ELSE SYCDCL2.CDCL_NM || '-' END )   || COMD_RRMK_C_Tmp."B.CDCL_NM" IS NULL
			  THEN
			  COMD_RRMK_C_Tmp.CDCL_ID || ' ' || ( CASE WHEN SYCDCL1.UP_CDCL_ID IN ('EORQ','LR','WD') THEN '' ELSE CD_NM_ENG.CD_NM_ENG || '-' END ) || COMD_RRMK_C_Tmp."A.CD_NM_ENG"
			  ELSE 
			  COMD_RRMK_C_Tmp.CDCL_ID || ' ' || ( CASE WHEN SYCDCL1.UP_CDCL_ID IN ('EORQ','LR','WD') THEN '' ELSE SYCDCL2.CDCL_NM || '-' END )   || COMD_RRMK_C_Tmp."B.CDCL_NM"
			  END AS COMD_RRMK_C	-- IF문 로직 확인 필요*/
		FROM (
			SELECT
				  T1.CDCL_ID
				, T1.CD_NM_ENG AS "A.CD_NM_ENG"
				, T2.UP_CDCL_ID AS "B.UP_CDCL_ID"
				, T2.CDCL_NM AS "B.CDCL_NM"
			FROM SYCODE T1 INNER JOIN SYCDCL T2 ON T1.CDCL_ID = T2.CDCL_ID
			) COMD_RRMK_C_Tmp
		INNER JOIN (
			SELECT DISTINCT CDCL_ID
			FROM QQ_Tmp 
			) QQ_Tmp
		ON COMD_RRMK_C_Tmp.CDCL_ID = QQ_Tmp.CDCL_ID
		LEFT JOIN (
			SELECT
				  CDCL_ID
				, UP_CDCL_ID
			FROM SYCDCL
			) SYCDCL1 
		ON COMD_RRMK_C_Tmp.CDCL_ID = SYCDCL1.CDCL_ID
		LEFT JOIN (
			SELECT  
				  CDCL_ID AS "B.UP_CDCL_ID"
				, CDCL_NM	
			FROM SYCDCL
			) SYCDCL2
		ON COMD_RRMK_C_Tmp."B.UP_CDCL_ID" = SYCDCL2."B.UP_CDCL_ID"
		LEFT JOIN (
			SELECT 
				  CDCL_ID AS "B.UP_CDCL_ID"
				, MIN(CD_NM_ENG) AS CD_NM_ENG
			FROM SYCODE
			GROUP BY CDCL_ID
			) CD_NM_ENG
		ON COMD_RRMK_C_Tmp."B.UP_CDCL_ID" = CD_NM_ENG."B.UP_CDCL_ID"
		) COMD_RRMK_C
	ON QQ_Tmp.CDCL_ID = COMD_RRMK_C.CDCL_ID
	) QQ
ON  SO.X10_EO_NO = QQ.X10_EO_NO
AND SO.A15_VPNO  = QQ.A15_VPNO
/**********************************************************************************************
	Dimension
**********************************************************************************************/
LEFT JOIN ( -- 협력사
	SELECT /*+ INDEX(T TABLE14_PK) */
		  VAAT_CO_CD
		, VEND_CD
		, MIN(VEND_NM_EXT) AS COF_NM
	FROM VMSTADM.TABLE14 T	/* *업체마스터 */
	GROUP BY VAAT_CO_CD, VEND_CD
	) COF_CD
ON  Fact.VAAT_CO_CD	= COF_CD.VAAT_CO_CD		-- [Fact]	VAAT_CO_CD&'|'&Trim(COF_CD) AS COF_CD_KEY
AND Fact.COF_CD		= COF_CD.VEND_CD		-- [COF_CD]	Exists(COF_CD_KEY, VAAT_CO_CD&'|'&VEND_CD)
LEFT JOIN ( -- 법인코드
	SELECT
		  CD_EXPL_SBC AS CORP_CD_KEY
		, MIN(CD_ID) AS CORP_CD
	FROM VMSTADM.TABLE15		/* 상세코드마스터 */
	WHERE CD_G_CD = 'S0037'
	GROUP BY CD_EXPL_SBC
	) CORP_CD
ON Fact.VAAT_CO_CD	= CORP_CD.CORP_CD_KEY	-- [Fact]		VAAT_CO_CD AS CORP_CD_KEY
											-- [CORP_CD]	Exists(CORP_CD_KEY, CD_EXPL_SBC)

