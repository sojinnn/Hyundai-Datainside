-- Vaatz 부품원가_원가분석상세_집계

/* 작성자 : 이소진
 * 작업내역 : 2025.05.21 최초 작성
 * 
 * DB Connection : GPOSADM_VER
 * 
 * [Target/Source 앱]
 * Vaatz_세부원가QVD생성
 * Vaatz_변경적재(부품원가)_NEW
 * Vaatz_변경적재(마스터外)_NEW2
 * 
 * [Fact Table]
 * TABLE1	구매원가 재료비정보
 * TABLE2	구매원가 가공비정보
 * TABLE3	구매원가 금형비정보
 * TABLE4	구매원가 기타비정보
 * 
 * [Master Table]
 * TABLE5	상세코드마스터
 * TABLE6	*업체마스터
 *  
 * */

/* 태블로-Qlik 간 건수 차이가 원가공통 관련 로직 때문이 아닌 Qlik 증분 추출로 인한 데이터 싱크 차이로 확인됨
 * Qlik과 값을 비교하여 검증할 수 없는 상황이므로 추후 현업 확인을 통해 값 검증 및 로직 확인 필요
 * 개발 시점 기준 태블로에서는 불필요한 로직으로 판단되어 주석처리 하였음 (2025.08.19)
 * 추후 로직 반영 필요 시 원가공통 관련 부분 주석 해제하여 적용 가능하나 
 * 추출 성능 이슈로 원가공통 부분은 마트화 필요할 것으로 보임
 * 
 * WITH Temp_T AS (
	SELECT
		  B00H.CRE_YYMM AS PROC_YYMM -- 년월 
		, B00H.VAAT_CO_CD -- 회사코드 
		, B00H.FIRM_CD    -- 업체코드 
--		, B00H.SVC_RQ_SN  -- 요청번호 
--		, B00H.VPNO       -- end품번 
--		, B00H.VPNO AS END품번
--		, B00H.PART_NM AS END품명  -- end품명
--		, P002.LRNK_VPNO AS SUB품번
--		, P002.PART_NM AS SUB품명
		, P002.LRNK_PART_FIRM_CD
		, P002.LRNK_VPNO
--		, P002.SUPI_PART_FIRM_CD
--		, P002.SUPI_VPNO
--		, P002.DATA_SN
		, P001.STUF_EXP_MGMT_SN  -- 재료비색인
		, P001.MFR_EXP_MGMT_SN   -- 가공비색인
		, P001.MEMU_EXP_SN       -- 금형비색인
		, P001.ETC_EXP_MGMT_SN   -- 기타비색인
	FROM (
		SELECT *
		FROM GPOSADM.TDWSP_SPC2B00H
		WHERE 1=1
			AND CRE_YYMM BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -1), 'YYYYMM') 	-- 최근 2개월
						 AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMM')
		) B00H
	INNER JOIN (
		SELECT *
		FROM GPOSADM.TDWSP_SPC2P002
		WHERE 1=1
			AND BASIS_YYMM BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -1), 'YYYYMM') 	-- 최근 2개월
						 AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMM')
		) P002
		ON  B00H.CRE_YYMM = P002.BASIS_YYMM
		AND B00H.VAAT_CO_CD = P002.VAAT_CO_CD
		AND B00H.FIRM_CD = P002.FIRM_CD
		AND B00H.SVC_RQ_SN = P002.SVC_RQ_SN
		AND B00H.VPNO = P002.VPNO
	INNER JOIN (
		SELECT *
		FROM GPOSADM.TDWSP_SPC2P001
		WHERE 1=1
			AND BASIS_YYMM BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -1), 'YYYYMM') 	-- 최근 2개월
						 AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMM')
		) P001
	ON  B00H.CRE_YYMM = P001.BASIS_YYMM
	AND B00H.VAAT_CO_CD = P001.VAAT_CO_CD
	AND B00H.FIRM_CD = P001.FIRM_CD
	AND P002.LRNK_PART_FIRM_CD = P001.LRNK_PART_FIRM_CD
	AND P002.LRNK_VPNO = P001.LRNK_VPNO
	AND P002.SUPI_PART_FIRM_CD = P001.SUPI_PART_FIRM_CD
	AND P002.SUPI_VPNO = P001.SUPI_VPNO
	AND P002.DATA_SN = P001.DATA_SN
	),
원가공통 AS (
	SELECT DISTINCT 
		  '재료비' || PROC_YYMM || VAAT_CO_CD || FIRM_CD || LRNK_PART_FIRM_CD || LRNK_VPNO || STUF_EXP_MGMT_SN AS KEY_PK
--		, '재료비'AS REC_FLG
--		, STUF_EXP_MGMT_SN AS REC_IDX  
	FROM Temp_T
	WHERE STUF_EXP_MGMT_SN <> 0
	UNION ALL 
	SELECT DISTINCT 
		  '가공비' || PROC_YYMM || VAAT_CO_CD || FIRM_CD || LRNK_PART_FIRM_CD || LRNK_VPNO || MFR_EXP_MGMT_SN AS KEY_PK
--		, '가공비'AS REC_FLG
--		, MFR_EXP_MGMT_SN AS REC_IDX  
	FROM Temp_T
	WHERE MFR_EXP_MGMT_SN <> 0
	UNION ALL 
	SELECT DISTINCT 
		  '금형비' || PROC_YYMM || VAAT_CO_CD || FIRM_CD || LRNK_PART_FIRM_CD || LRNK_VPNO || MEMU_EXP_SN AS KEY_PK
--		, '금형비'AS REC_FLG
--		, MEMU_EXP_SN AS REC_IDX  
	FROM Temp_T
	WHERE MEMU_EXP_SN <> 0
	UNION ALL 
	SELECT DISTINCT 
		  '기타비' || PROC_YYMM || VAAT_CO_CD || FIRM_CD || LRNK_PART_FIRM_CD || LRNK_VPNO || ETC_EXP_MGMT_SN AS KEY_PK
--		, '기타비'AS REC_FLG
--		, ETC_EXP_MGMT_SN AS REC_IDX  
	FROM Temp_T
	WHERE ETC_EXP_MGMT_SN <> 0
	),*/
WITH 재료비_T AS (
	SELECT 
		'재료비' AS REC_FLG
		, PROC_YYMM		
		, VAAT_CO_CD
		, FIRM_CD
		--, LRNK_PART_FIRM_CD
		--, LRNK_VPNO
		--, STUF_EXP_MGMT_SN AS REC_IDX
		--, 사용재료순번
		, 구매형태
		, 재료단위
		, 재료코드
		, 재료명칭
		, 수입코드
		, SUM(투입량) AS 투입량
		--, NetWt		
		--, 관세율
		--, 수입단가
		--, 재료단가
		--, 단위
		, SUM(사용량) AS 사용량
		, SUM(적용수량) AS 적용수량
		--, LOSS율
		--, 불량율
		--, 여유율
		--, SCRAP단가
		--, SCRAP중량
		--, 산폐단가
		, SUM(산폐비) AS 산폐비
		, SUM(재료관리비) AS 재료관리비
		, SUM(재료비) AS 재료비
		, COUNT(T1.KEY_PK) AS CNT_재료비
	FROM (
		SELECT 
			  '재료비' || BASIS_YYMM || VAAT_CO_CD || FIRM_CD || LRNK_PART_FIRM_CD || LRNK_VPNO || STUF_EXP_MGMT_SN AS KEY_PK
			, BASIS_YYMM AS PROC_YYMM -- 년월
			, VAAT_CO_CD -- 회사코드 
			, FIRM_CD    -- 업체코드 
			, LRNK_PART_FIRM_CD -- 자식업체코드 
			, LRNK_VPNO -- 자식부품번호 
			, STUF_EXP_MGMT_SN -- 재료비색인
	--		, STUF_USE_MGMT_SN AS 사용재료순번 
			, STUF_SCN_CD AS 구매형태	
			, STUF_UTM_CD AS 재료단위
			, STUF_MGMT_CD AS 재료코드
			, STUF_NM AS 재료명칭
			, IMPT_STUF_MGMT_CD AS 수입코드
			, STUF_TRWI_QTY AS 투입량
	--		, NET_WT AS NetWt			
	--		, CSDY_RT AS 관세율
	--		, GLB_IMPT_UNP AS 수입단가
	--		, STUF_UNP AS 재료단가
	--		, STUF_UTM_CD AS 단위
			, STUF_USE_QTY AS 사용량
			, UTM_PRDN_QTY AS 적용수량
	--		, LOSS_RTO AS LOSS율
	--		, STUF_BAD_RTO AS 불량율
	--		, RSV_RT AS 여유율
	--		, SCRP_UNP AS SCRAP단가
	--		, SCRP_WT AS SCRAP중량
	--		, IDW_TRTM_UNP AS 산폐단가
			, IDW_TRTM_EXP AS 산폐비
			, STUF_MGXP AS 재료관리비
			, STUF_EXP AS 재료비   
		FROM GPOSADM.TABLE1		/* 구매원가 재료비정보 */
		WHERE BASIS_YYMM BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -1), 'YYYYMM') 	-- 최근 2개월
						 AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMM')
		) T1
--	INNER JOIN 원가공통 T2 ON T1.KEY_PK = T2.KEY_PK
	GROUP BY 
		  PROC_YYMM 		
		, VAAT_CO_CD
		, FIRM_CD
		, 구매형태
		, 재료단위
		, 재료코드
		, 재료명칭
		, 수입코드
	),
가공비_T AS (
	SELECT 
		  '가공비' AS REC_FLG
		, PROC_YYMM 
		, VAAT_CO_CD
		, FIRM_CD
		, 공정명칭 
		, 기계명칭  
		, SUM(공정총원가) AS 공정총원가
		, SUM(인원) AS 인원
		, SUM(기계경비) AS 기계경비
		, SUM(일반관리비) AS 일반관리비 
		, SUM(가공비) AS 가공비   
		, SUM(경비) AS 경비
		, COUNT(T1.KEY_PK)  AS CNT_가공비
	FROM (
		SELECT 
			  '가공비' || BASIS_YYMM || VAAT_CO_CD || FIRM_CD || LRNK_PART_FIRM_CD || LRNK_VPNO || MFR_EXP_MGMT_SN AS KEY_PK
			, BASIS_YYMM AS PROC_YYMM -- 년월
			, VAAT_CO_CD -- 회사코드 
			, FIRM_CD    -- 업체코드 
			, LRNK_PART_FIRM_CD -- 자식업체코드 
			, LRNK_VPNO -- 자식부품번호
			, MFR_EXP_MGMT_SN -- 가공비색인
	--		, MFR_POW_SN AS 가공공정SEQ 
			, POW_NM AS 공정명칭
			, MFR_MC_NM AS 기계명칭 
			, MFR_GRSS_CST_AMT AS 공정총원가		
	--		, NET_WNED_HCT AS NetCt
			, MFR_CPSN AS 인원
	--		, PRLT_PART_QTY AS LOT		
			, MFR_MC_UEXP AS 기계경비
	--		, ADD_UEXP_RTO AS 추가경비율
			, GEN_MGXP AS 일반관리비
	--		, ERN_AMT AS 이윤
			, MFR_EXP AS 가공비		 
	--		, CVTY_QTY AS Cavity
	--		, MC_RUN_PREP_HCT AS 준비시간
	--		, PTM_WART AS 임율      
			, F_UEXP AS 경비
		FROM GPOSADM.TABLE2		/* 구매원가 가공비정보 */
		WHERE BASIS_YYMM BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -1), 'YYYYMM') 	-- 최근 2개월
						 AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMM')
		) T1
--	INNER JOIN 원가공통 T2 ON T1.KEY_PK = T2.KEY_PK
	GROUP BY
		  PROC_YYMM 
		, VAAT_CO_CD
		, FIRM_CD
		, 공정명칭 
		, 기계명칭
	),
금형비_T AS (
	SELECT
		  '금형비' AS REC_FLG
		, PROC_YYMM 
		, VAAT_CO_CD
		, FIRM_CD
		, SUM(금형비) AS 금형비
		, COUNT(T1.KEY_PK) AS CNT_금형비
	FROM (
		SELECT 
			  '금형비' || BASIS_YYMM || VAAT_CO_CD || FIRM_CD || LRNK_PART_FIRM_CD || LRNK_VPNO || MEMU_EXP_SN AS KEY_PK 
			, BASIS_YYMM AS PROC_YYMM -- 년월
			, VAAT_CO_CD -- 회사코드 
			, FIRM_CD    -- 업체코드 
			, LRNK_PART_FIRM_CD -- 자식업체코드 
			, LRNK_VPNO -- 자식부품번호 
			, MEMU_EXP_SN -- 금형비색인 
	--		, CD_SEQ AS 관리번호
			, PERM_RDMP_AMT AS 금형비
		FROM GPOSADM.TABLE3		/* 구매원가 금형비정보 */
		WHERE BASIS_YYMM BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -1), 'YYYYMM') 	-- 최근 2개월
						 AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMM')
		) T1
--	INNER JOIN 원가공통 T2 ON T1.KEY_PK = T2.KEY_PK
	GROUP BY 
		  PROC_YYMM 
		, VAAT_CO_CD
		, FIRM_CD
	),
기타비_T AS (
	SELECT
		  '기타비' AS REC_FLG
		, PROC_YYMM 
		, VAAT_CO_CD
		, FIRM_CD 
		, 유형구분
		, SUM(RD비) AS RD비
		, SUM(로열티) AS 로열티
		, SUM(불량비) AS 불량비
		, SUM(운반비) AS 운반비
		, SUM(파렛트비) AS 파렛트비
		, SUM(서열비) AS 서열비
		, SUM(추가비) AS 추가비
		, SUM(개발비) AS 개발비
		, COUNT(T1.KEY_PK) AS CNT_기타비
	FROM (
		SELECT 
			  '기타비' || BASIS_YYMM || VAAT_CO_CD || FIRM_CD || LRNK_PART_FIRM_CD || LRNK_VPNO || ETC_EXP_MGMT_SN AS KEY_PK
			, BASIS_YYMM AS PROC_YYMM -- 년월 
			, VAAT_CO_CD -- 회사코드 
			, FIRM_CD    -- 업체코드 
			, LRNK_PART_FIRM_CD -- 자식업체코드 
			, LRNK_VPNO -- 자식부품번호 
			, ETC_EXP_MGMT_SN -- 기타비색인 
			, WK_SCN_CD AS 유형구분
			, RTO_APL_RND_EXP AS RD비
			, RTO_APL_RYLT_EXP AS 로열티
			, RTO_APL_BEXP_EXP AS 불량비
			, PART_REXP AS 운반비
			, PPRT_PLLT_EXP AS 파렛트비
			, QEXP AS 서열비
			, ADD_EXP AS 추가비
			, PART_DVLP_EXP AS 개발비
		FROM GPOSADM.TABLE4		/* 구매원가 기타비정보 */
		WHERE BASIS_YYMM BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -1), 'YYYYMM') 	-- 최근 2개월
						 AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMM')
		) T1
--	INNER JOIN 원가공통 T2 ON T1.KEY_PK = T2.KEY_PK
	GROUP BY 
		  PROC_YYMM 
		, VAAT_CO_CD 
		, FIRM_CD
		, 유형구분
	),
코드 AS (
	SELECT
		  CD_ID
		, CD_EXPL_SBC
		, VAAT_CO_CD
		, CD_G_CD
		, GLB_LANG_CD
	FROM GPOSADM.TABLE5		/* 상세코드마스터 */
	)
SELECT 
	  LINK_T.REC_FLG
	, TO_DATE(LINK_T.PROC_YYMM || '01','YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, LINK_T.PROC_YYMM
	, LINK_T.VAAT_CO_CD
	, LINK_T.FIRM_CD
	, 업체정보.업체명
--	, 1 AS ROW_CNT
	, 재료비.구매형태
	, 재료비.구매형태명
	, 재료비.재료단위
	, 재료비.재료단위명
	, 재료비.재료코드
	, 재료비.재료명칭
	, 재료비.수입코드
	, 재료비.투입량
	, 재료비.사용량
	, 재료비.적용수량
	, 재료비.산폐비
	, 재료비.재료관리비
	, 재료비.재료비
	, 재료비.CNT_재료비
	, 가공비.공정명칭 
	, 가공비.기계명칭  
	, 가공비.공정총원가
	, 가공비.인원
	, 가공비.기계경비
	, 가공비.일반관리비 
	, 가공비.가공비   
	, 가공비.경비
	, 가공비.CNT_가공비
	, 금형비.금형비
	, 금형비.CNT_금형비
	, 기타비.유형구분
	, 기타비.RD비
	, 기타비.로열티
	, 기타비.불량비
	, 기타비.운반비
	, 기타비.파렛트비
	, 기타비.서열비
	, 기타비.추가비
	, 기타비.개발비
	, 기타비.CNT_기타비
/*----------------------------------- LINK_T ------------------------------------*/
FROM (
	SELECT DISTINCT REC_FLG, PROC_YYMM, VAAT_CO_CD, FIRM_CD FROM 재료비_T UNION ALL
	SELECT DISTINCT REC_FLG, PROC_YYMM, VAAT_CO_CD, FIRM_CD FROM 가공비_T UNION ALL
	SELECT DISTINCT REC_FLG, PROC_YYMM, VAAT_CO_CD, FIRM_CD FROM 금형비_T UNION ALL
	SELECT DISTINCT REC_FLG, PROC_YYMM, VAAT_CO_CD, FIRM_CD FROM 기타비_T
	) LINK_T
/*------------------------------------ 재료비 -------------------------------------*/
LEFT JOIN ( 
	SELECT 재료비_T.*, 코드_구매형태.구매형태명, 코드_재료단위.재료단위명
	FROM 재료비_T 
	LEFT JOIN (
		SELECT
			  CD_ID -- AS 구매형태
			, CD_EXPL_SBC AS 구매형태명
		FROM 코드
		WHERE VAAT_CO_CD = 'ALL'                       
		AND CD_G_CD = 'A0095'                     
		AND GLB_LANG_CD = 'KO'
		) 코드_구매형태 ON 재료비_T.구매형태 = 코드_구매형태.CD_ID		-- Exists(구매형태, CD_ID)
	LEFT JOIN (
		SELECT
			  CD_ID -- AS 재료단위
			, CD_EXPL_SBC AS 재료단위명
		FROM 코드
		WHERE VAAT_CO_CD = 'ALL'                       
		AND CD_G_CD = 'A0189'                     
		AND GLB_LANG_CD = 'KO' 
		) 코드_재료단위 ON 재료비_T.재료단위 = 코드_재료단위.CD_ID		-- Exists(재료단위, CD_ID)	
	) 재료비
ON  LINK_T.REC_FLG = 재료비.REC_FLG			-- [LINK_T]	AutoNumberHash128('재료비', PROC_YYMM, FIRM_CD, VAAT_CO_CD) AS KEY_PK
AND LINK_T.PROC_YYMM = 재료비.PROC_YYMM		-- [재료비]	AutoNumberHash128('재료비', PROC_YYMM, FIRM_CD, VAAT_CO_CD) AS KEY_PK
AND LINK_T.VAAT_CO_CD = 재료비.VAAT_CO_CD		
AND LINK_T.FIRM_CD = 재료비.FIRM_CD			
/*------------------------------------ 가공비 -------------------------------------*/
LEFT JOIN ( SELECT * FROM 가공비_T ) 가공비
ON  LINK_T.REC_FLG = 가공비.REC_FLG			-- [LINK_T]	AutoNumberHash128('가공비', PROC_YYMM, FIRM_CD, VAAT_CO_CD) AS KEY_PK
AND LINK_T.PROC_YYMM = 가공비.PROC_YYMM		-- [가공비]	AutoNumberHash128('가공비', PROC_YYMM, FIRM_CD, VAAT_CO_CD) AS KEY_PK
AND LINK_T.VAAT_CO_CD = 가공비.VAAT_CO_CD
AND LINK_T.FIRM_CD = 가공비.FIRM_CD
/*------------------------------------ 금형비 -------------------------------------*/
LEFT JOIN ( SELECT * FROM 금형비_T ) 금형비
ON  LINK_T.REC_FLG = 금형비.REC_FLG			-- [LINK_T]	AutoNumberHash128('금형비', PROC_YYMM, FIRM_CD, VAAT_CO_CD) AS KEY_PK
AND LINK_T.PROC_YYMM = 금형비.PROC_YYMM		-- [금형비]	AutoNumberHash128('금형비', PROC_YYMM, FIRM_CD, VAAT_CO_CD) AS KEY_PK
AND LINK_T.VAAT_CO_CD = 금형비.VAAT_CO_CD
AND LINK_T.FIRM_CD = 금형비.FIRM_CD
/*------------------------------------ 기타비 -------------------------------------*/
LEFT JOIN ( SELECT * FROM 기타비_T ) 기타비
ON  LINK_T.REC_FLG = 기타비.REC_FLG			-- [LINK_T]	AutoNumberHash128('기타비', PROC_YYMM, FIRM_CD, VAAT_CO_CD) AS KEY_PK
AND LINK_T.PROC_YYMM = 기타비.PROC_YYMM		-- [기타비]	AutoNumberHash128('기타비', PROC_YYMM, FIRM_CD, VAAT_CO_CD) AS KEY_PK
AND LINK_T.VAAT_CO_CD = 기타비.VAAT_CO_CD
AND LINK_T.FIRM_CD = 기타비.FIRM_CD
LEFT JOIN (
	SELECT 
		  VAAT_CO_CD
		, VEND_CD
		, VEND_NM_EXT AS 업체명
	FROM GPOSADM.TABLE6		/* *업체마스터 */
) 업체정보	
ON  LINK_T.VAAT_CO_CD = 업체정보.VAAT_CO_CD	-- [LINK_T]	AutoNumberHash128(VAAT_CO_CD, FIRM_CD) AS KEY_협력사
AND LINK_T.FIRM_CD = 업체정보.VEND_CD			-- [업체정보]	AutoNumberHash128(VAAT_CO_CD, VEND_CD) AS KEY_협력사

