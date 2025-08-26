-- Vaatz 업체선정_운영구도분석

/* 작성자 : 이소진
 * 작업내역 : 2025.05.28 최초 작성
 * 
 * DB Connection : LEGERCY_VER
 * 
 * [Target/Source 앱]
 * Vaatz_업체선정QVD생성_업무계
 * Vaatz_변경적재(마스터外)_NEW2	(TDWMA_MSTCDDET 참고)
 * 
 * [Table]
 * TABLE1	업체견적요청마스터
 * TABLE2	업체견적요청매핑정보
 * TABLE3	업체견적요청대상정보
 * TABLE4	운영구도마스터
 * TABLE5	P코드마스터
 * TABLE6	법인별 운영구도
 * TABLE7	운영구도별 업체관리
 * TABLE8	*업체마스터
 * TABLE9	상세코드마스터
 *  
 * */

/*------------------------------------- 입찰정보 -----------------------------------*/
WITH 입찰정보 AS (
	SELECT 
		  T1.법인코드
		, T1.업체코드
		, T1.운영구도코드
		, T1.견적번호
		, T1.견적차수
		, T1.입찰번호년도
		, T1.프로젝트코드
		, T1.품번
		, T1.낙찰여부
		, T1.홀딩사업체코드
		, T1.입찰대상여부
		, T1.업체선정여부
		, T1.CNT_입찰견적요청
		, 1 AS CNT_입찰정보
		, T2.P코드
		, T2.P코드명
		, T2.업체명
		, T2.운영구도명
		, T2.승상구분
		, T2.단위
		, T2.운영구도상태
		, T2.글로벌통합
		, T2.안전부품
		, T2.이력
		, T2.홀딩사
		, T2.업체사용여부
		, T2.입찰방식
		, T2."ProcDate"	
		, T2.업체수정일
	FROM (
		SELECT
			  NVL(DECODE(RQHD.FOIG_CO_CD, 'HMC', 'HKMC', 'KMC', 'HKMC', 'K1', 'HKMC', RQHD.FOIG_CO_CD), RQHD.DVLP_ORG_CO_CD) AS 법인코드 -- "운영구도코드법인"
			, RQSM.PART_FIRM_CD AS "업체코드"
			, RQHD.PB_CD AS "운영구도코드"
			, RQHD.BID_NO_SN AS "견적번호"
			, RQHD.BID_NO_NOS  AS "견적차수"
			, TRIM(RQHD.BID_NO_Y) AS "입찰번호년도" -- "견적년도(입찰번호년도)"		
			, RQMP.PRJ_CD AS "프로젝트코드"
			, RQMP.BID_IG_NO AS "품번"		
			, DECODE(RQSM.COSL_YN, 'A', '낙찰', '탈락')  AS "낙찰여부"
			, NVL(RQSM.HDCO_FIRM_CD, RQSM.PART_FIRM_CD) AS "홀딩사업체코드"
			, '참여' AS 입찰대상여부
			, DECODE(RQSM.COSL_YN, 'A', '낙찰', '미낙찰')  AS "업체선정여부"		-- IF(낙찰여부='낙찰',낙찰여부,'미낙찰') AS 업체선정여부
			, 1 AS CNT_입찰견적요청		
		FROM (
			SELECT BID_NO_Y, BID_NO_SN, BID_NO_NOS, FOIG_CO_CD, DVLP_ORG_CO_CD, PB_CD
			FROM VSAPADM.TABLE1		/* 업체견적요청마스터 */
			WHERE 1=1
				AND COSL_DT >= TO_DATE('20170101', 'YYYYMMDD')
				AND COSL_DT IS NOT NULL
			) RQHD
		INNER JOIN (
			SELECT BID_NO_Y, BID_NO_SN, BID_NO_NOS, PRJ_CD, BID_IG_NO
			FROM VSAPADM.TABLE2		/* 업체견적요청매핑정보 */
			WHERE 1=1
				AND FIN_STEP_YN = 'Y'
			) RQMP
		ON  RQHD.BID_NO_Y = RQMP.BID_NO_Y
		AND RQHD.BID_NO_SN = RQMP.BID_NO_SN
		AND RQHD.BID_NO_NOS = RQMP.BID_NO_NOS
		INNER JOIN (
			SELECT BID_NO_Y, BID_NO_SN, BID_NO_NOS, PART_FIRM_CD, COSL_YN, HDCO_FIRM_CD
			FROM VSAPADM.TABLE3		/* 업체견적요청대상정보 */
			WHERE 1=1
				AND BID_SUBJ_YN = 'A'
				AND FIRM_SCN_CD <> '4'
			) RQSM
		ON  RQMP.BID_NO_Y = RQSM.BID_NO_Y
		AND RQMP.BID_NO_SN = RQSM.BID_NO_SN
		AND RQMP.BID_NO_NOS = RQSM.BID_NO_NOS
		) T1	-- 입찰정보_TMP
	INNER JOIN (
		SELECT
			  PBDT.DVLP_ORG_CO_CD AS "법인코드"
			, PBVD.PART_FIRM_CD AS "업체코드"
			, PBMT.PB_CD AS "운영구도코드"
			, CDMT.PCD AS "P코드"
			, CDMT.PCD_NM AS "P코드명"	
			, PBMT.PB_NM AS "운영구도명" -- "운영구도코드명"	
			, GETMSTCDDET('ALL', 'S0940', CDMT.BIZ_CD, 'KO', '') AS "승상구분"
			, GETMSTCDDET('ALL', 'S0941', CDMT.UNIT_CD, 'KO', '') AS "단위"
			, DECODE(PBMT.USE_YN, 'Y', '사용중', '사용중지') AS "운영구도상태"
			, PBMT.GLB_ITG_CD AS "글로벌통합"
			, PBMT.SFT_CD AS "안전부품"
			, PBMT.DVLP_CSDT_IMTR_SBC AS "이력"	
			, FNC_GET_FIRMNM(PBVD.PART_FIRM_CD) AS "업체명"
			, PBVD.HOLDING_CD AS "홀딩사"
			, PBVD.BID_SUBJ_YN AS "업체사용여부"
			, GETMSTCDDET('ALL', 'A0025', PBDT.COSL_WAY_CD, 'KO', '') AS "입찰방식"
			, PBVD.INP_DT + INTERVAL '9' HOUR AS "ProcDate" -- "업체등록일"		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
			, PBVD.FIN_ALTR_DT + INTERVAL '9' HOUR AS "업체수정일"					-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		FROM VSAPADM.TABLE4 PBMT		/* 운영구도마스터 */
		INNER JOIN VMSTADM.TABLE5 CDMT ON PBMT.PCD 	= CDMT.PCD			/* P코드마스터 */
		INNER JOIN VSAPADM.TABLE6 PBDT ON PBMT.PB_CD = PBDT.PB_CD		/* 법인별 운영구도 */
		INNER JOIN (
			SELECT
				  T1.DVLP_ORG_CO_CD
				, T1.PB_CD
				, T1.PART_FIRM_CD
				, T1.BID_SUBJ_YN
				, T1.INP_DT
				, T1.FIN_ALTR_DT
				, T2.HOLDING_CD
			FROM VSAPADM.TABLE7 T1			/* 운영구도별 업체관리 */
			LEFT JOIN VMSTADM.TABLE8 T2		/* *업체마스터 */
			ON  T1.DVLP_ORG_CO_CD = T2.VAAT_CO_CD
			AND T1.PART_FIRM_CD = T2.VEND_CD
			) PBVD
		ON  PBDT.DVLP_ORG_CO_CD = PBVD.DVLP_ORG_CO_CD
		AND PBDT.PB_CD = PBVD.PB_CD
		) T2	-- 운영구도
	ON  T1.법인코드 = T2.법인코드
	AND T1.업체코드 = T2.업체코드
	AND T1.운영구도코드 = T2.운영구도코드
	)
SELECT 
	  F.*
	, F.입찰번호년도 || '-' || F.견적번호 || '-' || F.견적차수 AS 입찰번호
	, F.입찰번호년도 || '-' || F.견적번호 || '-' || F.견적차수 AS 입찰번호1
	, F.업체코드 || '-' || F.업체명 AS "업체코드-업체명"
	, CASE WHEN F.입찰대상여부 = '참여' THEN F.CNT_입찰견적요청 ELSE 0 END AS 입찰회수
	, CASE WHEN F.업체선정여부 = '낙찰' THEN F.CNT_입찰견적요청 ELSE 0 END AS 낙찰회수
	, LINK_T.T_GUBUN
	, LINK_T.CNT_LINK
	, 홀딩사별업체수.지코드법인
	, 홀딩사별업체수.업체수
	, P코드.사업영역코드
	, P코드.단위코드
	, P코드.대표PNO
	, P코드.품목분류명
	, P코드.사용여부_P코드
	, P코드.입력일자_P코드
	, P코드.입력자ID_P코드
	, P코드.최종변경일자_P코드
	, P코드.최종변경사용자ID_P코드
	, P코드.접속IP주소_P코드
	, P코드.IPE_VAAT_CO_CD_P코드
	, P코드.IPE_DEPT_CD_P코드
	, P코드.CNT_P코드
	, 코드_업체선정방법.입찰방식명
	, 코드_업체선정방법.입찰방식_S
FROM 입찰정보 F
LEFT JOIN (
	SELECT DISTINCT 
		  '입찰정보' AS T_GUBUN		
		, 법인코드 
		, 업체코드
		, 운영구도코드
		, 1 AS CNT_LINK
	FROM 입찰정보
	) LINK_T
ON  F.법인코드 	= LINK_T.법인코드			-- [T1] AutoNumberHash128(운영구도코드법인&업체코드&운영구도코드) AS LINK_KEY
AND F.업체코드 	= LINK_T.업체코드
AND F.운영구도코드 	= LINK_T.운영구도코드
/*----------------------------------- Dimension ----------------------------------*/
LEFT JOIN ( 
	SELECT DISTINCT 
	--  KEY_HOLD	-- AutoNumberHash128(운영구도코드,법인코드) AS KEY_HOLD
	  운영구도코드
	, 법인코드
	, 운영구도코드 || '-' || 법인코드 AS 지코드법인
	, COUNT(DISTINCT 홀딩사업체코드) AS 업체수
	FROM 입찰정보
	GROUP BY 운영구도코드, 법인코드
	) 홀딩사별업체수
ON  F.운영구도코드 = 홀딩사별업체수.운영구도코드	-- [입찰정보]	AutoNumberHash128(운영구도코드,법인코드) AS KEY_HOLD
AND F.법인코드 = 홀딩사별업체수.법인코드
LEFT JOIN (
	SELECT 
	  PCD								AS P코드 
	, BIZ_CD							AS 사업영역코드
	, UNIT_CD							AS 단위코드
	, UPG_NO							AS 대표PNO
	, PCD_NM							AS 품목분류명
	, USE_YN							AS 사용여부_P코드
	, INP_DT + INTERVAL '9' HOUR		AS 입력일자_P코드			-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, IPE_ID							AS 입력자ID_P코드
	, FIN_ALTR_DT + INTERVAL '9' HOUR	AS 최종변경일자_P코드		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, FIN_CHGR_USER_ID					AS 최종변경사용자ID_P코드
	, CNNC_IP_ADR						AS 접속IP주소_P코드
	, IPE_VAAT_CO_CD					AS IPE_VAAT_CO_CD_P코드
	, IPE_DEPT_CD						AS IPE_DEPT_CD_P코드
	, 1 								AS CNT_P코드
	FROM VMSTADM.TABLE5
	) P코드
ON F.P코드 = P코드.P코드
LEFT JOIN (
	SELECT DISTINCT
		  CD_ID -- AS 입찰방식
		, CD_EXPL_SBC AS 입찰방식명
		, CD_ID AS 입찰방식_S
	FROM VMSTADM.TABLE9		/* 상세코드마스터 */
	WHERE 1=1
		AND CD_G_CD = 'A0025'
		AND GLB_LANG_CD = 'KO'
	) 코드_업체선정방법
ON F.입찰방식 = 코드_업체선정방법.입찰방식명	-- [코드_업체선정방법] Exists(입찰방식, CD_ID) ※※※※※ 코드_업체선정방법 CD_ID와 맵핑하면 NULL. 확인필요
/* 입낙찰회수 테이블 제외 (태블로에서 불필요)
 * AutoNumberHash128(입찰번호년도,운영구도코드,법인코드,업체코드) AS KEY_CNT
 * AutoNumberHash128(운영구도코드,법인코드,업체코드) AS KEY_CNT2
 * AutoNumberHash128(법인코드,업체코드) AS KEY_CNT3
 * AutoNumberHash128(업체코드) AS KEY_CNT4
 * LEFT JOIN ( 
	SELECT 
		  입찰번호년도
		, 운영구도코드
		, 법인코드
		, 업체코드
		, SUM( CASE WHEN 입찰대상여부 = '참여' THEN CNT_입찰견적요청 ELSE 0 END ) AS 입찰회수
		, SUM( CASE WHEN 업체선정여부 = '낙찰' THEN CNT_입찰견적요청 ELSE 0 END ) AS 낙찰회수
	FROM 입찰정보
	GROUP BY 입찰번호년도, 운영구도코드, 법인코드, 업체코드
	) 입낙찰회수*/
