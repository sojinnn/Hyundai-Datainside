-- Vaatz 부품개발_EO 발행현황

/* 작성자 : 이소진
 * 작업내역 : 2025.05.15 최초 작성 (윤해림)
 * 			2025.06.10 수정
 * 
 * DB Connection : LEGERCY_VER
 * 
 * [Target/Source 앱]
 * Vaatz_변경적재(부품개발)
 * Vaatz_초기적재(부품개발)_Ext
 * Vaatz_변경적재(마스터外)_NEW2 * 
 * 
 * [Table - EXTERNALDB(XXEBOM)]
 * TABLE1
 * 
 * [Table]
 * TABLE2		상세코드마스터
 * TABLE3		EO정보 마스터
 * TABLE4		EO접수정보
 * TABLE5		EO공유 EO유형별 회사정보
 * TABLE6		*부서코드
 * TABLE7		*사용자관리마스터
 * 
 * */

/*------------------------------------- Fact ------------------------------------*/
WITH DPTCD AS (
	SELECT
		VAAT_CO_CD
		, DEPT_CD
		, OPS_NM
	FROM VMSTADM.TABLE6		/* *부서코드 */
	WHERE USE_YN = 'Y'
	),
CDDET AS (
	SELECT
		  CD_G_CD
		, CD_EXPL_SBC
		, CD_ID
	FROM VMSTADM.TABLE2		/* 상세코드마스터 */
	WHERE 1=1
	AND VAAT_CO_CD = 'ALL'
	AND GLB_LANG_CD = 'KO'
	)
SELECT 
	  Fact.*
	, RSST_OPS_CD.OPS_NM
	, ACPC_CRGR_ID.ACPC_CRGR_NM
	, EO_ALTR_SBC_CD.EO_ALTR_SBC_NM
	, EO_ID_ST_CD.EO_ID_ST_NM
FROM (
	SELECT 
		  A.EO_ID_ST_CD
		, A.EO_TYPE_SCN_CD
		, A.EO_ALTR_SBC_CD
		, A.RSST_CRGR_NM
		, A.RSST_OPS_CD
		, A.RSST_VAAT_CO_CD
		, A.EO_ATTC_D_CD
		, A.EO_ATTC_C_CD
		, A.EO_ATTC_B_CD
		, A.EO_ATTC_A_CD
		, A.EO_I_YMD
		, A.EO_WDT_YMD
		, A."ProcDate"
		, A.VEHL_MDY_CD
		, A.EO_NO
		, SUBSTR(A.EO_NO,1,1) AS EO_NO_FIRST
		, A."추출필터"
		, B.ACPC_YMD
		, B.ACPC_CRGR_ID
		, B.VAAT_CO_CD
		, V.DSGN_COST
		, V."Sign_OD01_RDCV_D"
	FROM (
		SELECT
			  EO_ID_ST_CD
			, EO_TYPE_SCN_CD
			, EO_ALTR_SBC_CD
			, RSST_CRGR_NM
			, RSST_OPS_CD
			, RSST_VAAT_CO_CD
			, EO_ATTC_D_CD
			, EO_ATTC_C_CD
			, EO_ATTC_B_CD
			, EO_ATTC_A_CD
			, TO_DATE(EO_I_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS EO_I_YMD  		-- EO배포년월일	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
			, TO_DATE(EO_WDT_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS EO_WDT_YMD 	-- EO배포년월일	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
			, TO_DATE(EO_WDT_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"   	-- EO배포년월일	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
			, VEHL_MDY_CD
			, TRIM(EO_NO) AS EO_NO
			, CASE WHEN TO_DATE(EO_WDT_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR >= TRUNC(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -60),'MM')
				   THEN 'TRUE' 
				   ELSE 'FALSE'
				   END AS "추출필터"
		FROM VPDMADM.TABLE3		/* EO정보 마스터 */
		WHERE EO_WDT_YMD BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -61), 'YYYYMMDD') 	-- 최근 5년
							 AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMMDD')
		) A
	LEFT JOIN (
		SELECT 
			  TO_DATE(ACPC_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS ACPC_YMD
			, ACPC_CRGR_ID
			, VAAT_CO_CD
			, TRIM(EO_NO) AS EO_NO
		FROM VPDMADM.TABLE4		/* EO접수정보 */
		) B
	ON A.EO_NO = B.EO_NO
	LEFT JOIN (
		SELECT EO_TYPE_SCN_CD
		FROM VPDMADM.TABLE5		/* EO공유 EO유형별 회사정보 */
		WHERE VAAT_CO_CD = 'HKMC'
		) C
	ON A.EO_TYPE_SCN_CD = C.EO_TYPE_SCN_CD
	LEFT JOIN (
		SELECT 
			  TRIM(EONO) AS EO_NO
			, OD01_RDCV_D AS DSGN_COST    -- 설계원가증감액
			, SIGN(OD01_RDCV_D) AS "Sign_OD01_RDCV_D"
		FROM XXEBOM.TABLE1@EXTERNALDB
		) V
	ON A.EO_NO = V.EO_NO
	) Fact
/**********************************************************************************************
	Dimension
**********************************************************************************************/
-- 부서
LEFT JOIN ( 
	SELECT 
		  VAAT_CO_CD
		, DEPT_CD
		, MAX(OPS_NM) AS OPS_NM  -- PUR_CHRG_NM
	FROM DPTCD
	GROUP BY VAAT_CO_CD, DEPT_CD
	UNION ALL 
	SELECT 
		  'HKMC' AS VAAT_CO_CD
		, DEPT_CD
		, MAX(OPS_NM) AS OPS_NM  -- PUR_CHRG_NM
	FROM DPTCD
	GROUP BY DEPT_CD
	) RSST_OPS_CD
ON  Fact.RSST_VAAT_CO_CD = RSST_OPS_CD.VAAT_CO_CD		-- [Fact]			RSST_VAAT_CO_CD &'|'& RSST_OPS_CD AS RSST_OPS_CD_Key
AND Fact.RSST_OPS_CD 	 = RSST_OPS_CD.DEPT_CD			-- [RSST_OPS_CD]	Exists(RSST_OPS_CD_Key, OPS_CD_Key)	-> VAAT_CO_CD&'|'&DEPT_CD AS OPS_CD_Key
-- 접수담당자이름
LEFT JOIN (
	SELECT
		  CRTN_VAAT_CO_CD
		, USER_ID
		, USER_NM_EXT AS ACPC_CRGR_NM
	FROM VMSTADM.TABLE7		/* *사용자관리마스터 */
	) ACPC_CRGR_ID
ON  Fact.VAAT_CO_CD 	= ACPC_CRGR_ID.CRTN_VAAT_CO_CD	-- [Fact]			VAAT_CO_CD&'|'&ACPC_CRGR_ID AS ACPC_CRGR_ID_Key
AND Fact.ACPC_CRGR_ID 	= ACPC_CRGR_ID.USER_ID			-- [ACPC_CRGR_ID]	Exists(ACPC_CRGR_ID_Key, CRTN_VAAT_CO_CD&'|'&USER_ID)
-- EO변경내용명
LEFT JOIN (	
	SELECT
		  CD_EXPL_SBC AS EO_ALTR_SBC_NM
		, CD_ID AS EO_ALTR_SBC_CD
	FROM CDDET
	WHERE CD_G_CD = 'A0084'
	) EO_ALTR_SBC_CD
ON  Fact.EO_ALTR_SBC_CD = EO_ALTR_SBC_CD.EO_ALTR_SBC_CD	-- Exists(EO_ALTR_SBC_CD, CD_ID)
-- EOID상태명
LEFT JOIN (	
	SELECT
		  CD_EXPL_SBC AS EO_ID_ST_NM
		, CD_ID AS EO_ID_ST_CD
	FROM CDDET
	WHERE CD_G_CD = 'A0085'
	) EO_ID_ST_CD
ON  Fact.EO_ID_ST_CD = EO_ID_ST_CD.EO_ID_ST_CD		-- Exists(EO_ID_ST_CD, CD_ID)
