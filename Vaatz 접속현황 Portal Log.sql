-- Vaatz 접속현황 Portal Log

/* 작성자 : 이소진
 * 작업내역 : 2025.05.20 최초 작성
 * 
 * DB Connection : GPOSADM_VER
 * 
 * [Target/Source 앱]
 * Vaatz_변경적재(마스터外)_NEW2
 * 
 * [Table]
 * TABLE1		CRUD에 대한 로그
 * TABLE2		로그인 및 로그아웃에 대한 로그
 * TABLE3		*사용자관리마스터
 *  
 * */

/*-------------------------------- QVD Allocation --------------------------------*/
WITH TABLE1 AS (
	SELECT
		  ORA_HASH(SEQ || USER_ID || REG_DT || USER_IP || SCH_TYPE) AS HashKey
		, REG_DT + INTERVAL '9' HOUR AS REG_DT	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, CORP_GB
		, LANG_CD
		, USER_ID
		, USER_IP
		, SEQ
		, SYS_CD
		, SCR_ID
		, SCR_NM
		, POPUP_NM
		, CONTROLLER
		, SCH_TYPE
		, OPEN_INFO
	FROM GPOSADM.TABLE1		/* CRUD에 대한 로그 */	
	),
TABLE2 AS (
	SELECT
		  L_DATE + INTERVAL '9' HOUR AS L_DATE	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, CORP_GB
		, LANG_CD
		, USER_ID
		, USER_IP
		, SEQ
		, L_TIME
		, L_TYPE
		, SESS_ID
	FROM GPOSADM.TABLE2	/* 로그인 및 로그아웃에 대한 로그 */
	)
/*----------------------------------- LINK_LOG -----------------------------------*/
SELECT
	  LINK_LOG.LOG_GUB
	, LINK_LOG."ProcDate"
	, LINK_LOG.CORP_GB
	, LINK_LOG.LANG_CD
	, LINK_LOG.USER_ID
	, LINK_LOG.USER_IP
	, CRUD_LOG.LOG_CLUD_SEQ
	, CRUD_LOG.SYS_CD
	, CRUD_LOG.SCR_ID
	, CRUD_LOG.SCR_NM
	, CRUD_LOG.POPUP_NM
	, CRUD_LOG.CONTROLLER
	, CRUD_LOG.REG_DT
	, CRUD_LOG.REG_DT1
	, CRUD_LOG.SCH_TYPE
	, CRUD_LOG.OPEN_INFO
	, CRUD_LOG._CNT_LOG_CRUD
	, INOUT_LOG.LOG_INOUT_SEQ
	, INOUT_LOG.L_DATE
	, INOUT_LOG.L_DATE1
	, INOUT_LOG.L_TIME
	, INOUT_LOG.L_TYPE
	, INOUT_LOG.SESS_ID
	, INOUT_LOG._CNT_LOG_INOUT
	, MSTUSRCD.VAAT_CORP_CD
	, MSTUSRCD.VAAT_CO_CD
	, MSTUSRCD.USER_NM_EXT
	, MSTUSRCD.USER_NM_ENG
	, MSTUSRCD.DEPT_CD
	, MSTUSRCD.UP_DEPT_CD
	, MSTUSRCD.EMAIL
	, MSTUSRCD.COUNTRY
	, MSTUSRCD.GLB_LANG_CD
	, MSTUSRCD.RIGHT_GB
	, MSTUSRCD.CRTN_VAAT_CO_CD
FROM (
	SELECT DISTINCT
		  'CRUD' AS LOG_GUB
		, REG_DT AS "ProcDate"
		, CORP_GB
		, LANG_CD
		, USER_ID
		, USER_IP
	FROM TABLE1
	UNION ALL
	SELECT DISTINCT
		  'INOUT' AS LOG_GUB
		, L_DATE AS "ProcDate"
		, CORP_GB
		, LANG_CD
		, USER_ID
		, USER_IP
	FROM TABLE2
	) LINK_LOG
/*----------------------------------- CRUD_LOG -----------------------------------*/
LEFT JOIN (
	SELECT		
		  CORP_GB
		, LANG_CD
		, USER_ID
		, USER_IP
		, SEQ AS LOG_CLUD_SEQ
		, SYS_CD
		, SCR_ID
		, SCR_NM
		, POPUP_NM
		, CONTROLLER
		, REG_DT AS REG_DT		-- datetime
		, REG_DT AS REG_DT1		-- date
		, SCH_TYPE
		, OPEN_INFO
		, 1 AS _CNT_LOG_CRUD
	FROM TABLE1
	) CRUD_LOG
ON  LINK_LOG.CORP_GB = CRUD_LOG.CORP_GB		-- [LINK_LOG]	AutoNumberHash128(CORP_GB, LANG_CD, TEXT(USER_ID), USER_IP, DATE(Year(REG_DT)&'-'&Month(REG_DT)&'-'&Day(REG_DT),'YYYY-MM-DD')) AS LOG_KEY
AND LINK_LOG.LANG_CD = CRUD_LOG.LANG_CD		-- [CRUD_LOG]	AutoNumberHash128(CORP_GB, LANG_CD, TEXT(USER_ID), USER_IP, DATE(Year(REG_DT)&'-'&Month(REG_DT)&'-'&Day(REG_DT),'YYYY-MM-DD')) AS LOG_KEY
AND LINK_LOG.USER_ID = CRUD_LOG.USER_ID
AND LINK_LOG.USER_IP = CRUD_LOG.USER_IP
AND LINK_LOG."ProcDate" = CRUD_LOG.REG_DT
/*---------------------------------- INOUT_LOG -----------------------------------*/
LEFT JOIN (
	SELECT	
		  CORP_GB
		, LANG_CD
		, USER_ID
		, USER_IP
		, SEQ AS LOG_INOUT_SEQ
		, L_DATE			-- datetime
		, L_DATE AS L_DATE1	-- date
		, L_TIME
		, L_TYPE
		, SESS_ID
		, 1 AS _CNT_LOG_INOUT
	FROM TABLE2 
	) INOUT_LOG
ON  LINK_LOG.CORP_GB = INOUT_LOG.CORP_GB	-- [LINK_LOG]	AutoNumberHash128(CORP_GB, LANG_CD, TEXT(USER_ID), USER_IP, DATE(Year(REG_DT)&'-'&Month(REG_DT)&'-'&Day(REG_DT),'YYYY-MM-DD')) AS LOG_KEY
AND LINK_LOG.LANG_CD = INOUT_LOG.LANG_CD	-- [INOUT_LOG]	AutoNumberHash128(CORP_GB, LANG_CD, TEXT(USER_ID), USER_IP, DATE(Year(L_DATE)&'-'&Month(L_DATE)&'-'&Day(L_DATE),'YYYY-MM-DD')) AS LOG_KEY 
AND LINK_LOG.USER_ID = INOUT_LOG.USER_ID
AND LINK_LOG.USER_IP = INOUT_LOG.USER_IP
AND LINK_LOG."ProcDate" = INOUT_LOG.L_DATE
/*---------------------------------- MSTUSRCD ------------------------------------*/
LEFT JOIN (
	SELECT
	  VAAT_CORP_CD
	, USER_ID
	, VAAT_CO_CD
	, USER_NM_EXT
	, USER_NM_ENG
	, DEPT_CD
	, UP_DEPT_CD
	, EMAIL
	, COUNTRY
	, GLB_LANG_CD
	, RIGHT_GB
	, CRTN_VAAT_CO_CD
	FROM GPOSADM.TABLE3		/* *사용자관리마스터 */
	) MSTUSRCD
ON  LINK_LOG.CORP_GB = MSTUSRCD.VAAT_CORP_CD	-- [LINK_LOG]	AutoNumberHash128(CORP_GB, TEXT(USER_ID)) AS USER_KEY 
AND LINK_LOG.USER_ID = MSTUSRCD.USER_ID			-- [MSTUSRCD]	AutoNumberHash128(VAAT_CORP_CD, TEXT(USER_ID)) AS USER_KEY

