-- Vaatz 부품원가_원가분석-2

/* 작성자 : 이소진
 * 작업내역 : 2025.05.22 최초 작성
 * 
 * DB Connection : GPOSADM_VER
 * 
 * [Target/Source 앱]
 * Vaatz_원가분석QVD생성
 * Vaatz_변경적재(부품원가)_NEW
 * Vaatz Single Custom 
 * Vaatz_초기적재(업체관리)
 * 
 * [Table]
 * TABLE1				*업체마스터
 * TABLE2	홀딩사 정보
 * TABLE3				변동대상헤더
 * TABLE4				구매원가 Tree 정보			> 인덱스 확인
 * TABLE5				구매원가 Structure정보
 * TABLE6				구매원가 END ITEM 집계
 * TABLE7				구매원가 SUB PART 집계
 * TABLE8				구매원가유사모듈단가정보
 *  
 * */

/*--------------------------------- Data Load_분석계 -------------------------------*/
WITH MSTSIMMS AS (
	SELECT 
		  VEND_CD
		, VEND_NM_EXT
		, VEND_NM_ENG
		, VAAT_CO_CD
	FROM GPOSADM.TABLE1	/* *업체마스터 */
	),
업체마스터 AS (
	SELECT 
		  T1.VEND_CD
		, CASE WHEN T1.VEND_CD <> T3.HOLDING_CD
		  THEN 'X' 
		  ELSE 'O' 
		  END AS VEND_PANJUNG
		, T1.VEND_CD AS PART_FIRM_CD
		, CASE WHEN T3.HOLDING_CD IS NULL
		  THEN T1.VEND_CD
		  ELSE T3.HOLDING_CD 
		  END AS HOLDING_CD
		, T1.VEND_EXT
		, T2.VEND_ENG
		, CASE WHEN T1.CNT_EXT >= 1
		  THEN T1.VEND_EXT
		  ELSE T2.VEND_ENG
		  END AS VEND_NM
		, T1.CNT_EXT
		, T2.CNT_ENG 
	FROM (
		SELECT 
			  VEND_CD
			, MAX(VEND_NM_EXT) AS VEND_EXT
			, COUNT(*) AS CNT_EXT 
		FROM MSTSIMMS
		WHERE VAAT_CO_CD = 'HKMC' 
		GROUP BY VEND_CD 
		) T1
	INNER JOIN (
		SELECT 
			  VEND_CD
			, MAX(VEND_NM_ENG) AS VEND_ENG
			, COUNT(*) AS CNT_ENG 
		FROM MSTSIMMS
		WHERE VAAT_CO_CD <> 'HKMC' 
		GROUP BY VEND_CD
		) T2
	ON T1.VEND_CD = T2.VEND_CD
	INNER JOIN (
		SELECT 
		--	  DISTINCT
			  VEND_CD
			, MAX(HOLDING_CD) AS HOLDING_CD
		--	, COUNT(DISTINCT HOLDING_CD) AS CNT_HOLD1
		--	, CORP_GB
		--	, STD_YEAR
		--	, REPR_CD
		--	, APPLY_GB
		--	, STAT
		--	, INPUT_DATE
		--	, INPUT_TIME
		--	, INPUT_EMP_NO
		--	, MODI_DATE
		--	, MODI_TIME
		--	, MODI_EMP_NO
		--	, ETL_LOAD_DATE
		FROM GPOSADM.TABLE2	/* 홀딩사 정보 */
		GROUP BY VEND_CD
		) T3
	ON T1.VEND_CD = T3.VEND_CD
	)
/*---------------------------------- Data Loading --------------------------------*/
SELECT
	  Summary.생성년월
	, Summary."ProcDate"
	, Summary.법인코드 
	, Summary.업체코드 
	, Summary.요청번호 
	, Summary.END품번
	, Summary.END품명
	, Summary.단가
	, Summary.SUB품번
	, Summary.SUB품명
	, Summary.직거래사급여부
	, Summary.직거래업체코드
	, Summary.직거래사급단가
	, Summary.외주재관비
	, Summary.SUB단가
	, Summary.재료총원가
	, Summary.가공총원가
	, Summary.기타비
	, Summary.금형상각비
	, Summary."U/S"
	, Summary.SUM_CNT
	, 업체정보.업체명
	, 직거래업체정보.직거래업체명
FROM (
	SELECT 
		  생성년월
		, TO_DATE(생성년월 || '01', 'YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, 법인코드 
		, 업체코드 
		, 요청번호 
		, END품번
		, END품명
		, 단가
		, SUB품번
		, SUB품명
		, 직거래사급여부
		, 직거래업체코드
		, 직거래사급단가
		, 외주재관비
		, SUB단가
		, 재료총원가
		, 가공총원가
		, 기타비
		, 금형상각비
		, SUM(APPW2_QTY) AS "U/S"
		, 1 AS SUM_CNT
	FROM (
		SELECT 
			  B00H.CRE_YYMM AS 생성년월
			, B00H.VAAT_CO_CD AS 법인코드      
			, B00H.FIRM_CD AS 업체코드 
			, B00H.SVC_RQ_SN AS 요청번호 
			, B00H.VPNO AS END품번
			, B00H.PART_NM AS END품명
			, S001.DTRM_PCE AS 단가
			, P002.LRNK_VPNO AS SUB품번
			, P002.PART_NM AS SUB품명
			, P002.LRNK_PART_FIRM_CD
			, P002.SUPI_PART_FIRM_CD
			, P002.SUPI_VPNO
			, P002.DATA_SN
			, P002.ROW_SN
			, P001.SIM_MDUL_SN
			, S003.BZTC_TYPE_CD  AS 직거래사급여부
			, S003.SIM_MDUL_PART_AMT AS 외주재관비        
			, S003.SAPT_UNP AS SUB단가
			, S003.STUF_GRSS_CST_AMT AS 재료총원가
			, S003.MFR_GRSS_CST_AMT AS 가공총원가
			, S003.ETC_GRSS_CST_AMT AS 기타비
			, S003.MEMU_RDMP_EXP AS 금형상각비
			, S003.APPW2_QTY
			, P010.SIM_PART_FIRM_CD AS 직거래업체코드
			, P010.SIM_MDUL_PART_AMT AS 직거래사급단가 
		FROM (
			SELECT 
				  CRE_YYMM -- AS 생성년월
				, VAAT_CO_CD -- AS 법인코드      
				, FIRM_CD -- AS 업체코드 
				, SVC_RQ_SN -- AS 요청번호 
				, VPNO -- AS END품번
				, PART_NM -- AS END품명
			FROM GPOSADM.TABLE3		/* 변동대상헤더 */		-- 48,453,177
			WHERE CRE_YYMM BETWEEN TO_CHAR(SYSDATE - INTERVAL '60' MONTH,'YYYYMM') AND TO_CHAR(SYSDATE,'YYYYMM')	-- 1,877,723
			) B00H
		INNER JOIN(		-- END 집계
			SELECT
				  BASIS_YYMM -- AS 생성년월
				, VAAT_CO_CD -- AS 법인코드  
				, FIRM_CD -- AS 업체코드  
				, SVC_RQ_SN -- AS 요청번호 
				, VPNO -- AS END품번
				, DTRM_PCE -- AS 단가
			FROM GPOSADM.TABLE6	/* 구매원가 END ITEM 집계 */		-- 47,453,521
			WHERE BASIS_YYMM BETWEEN TO_CHAR(SYSDATE - INTERVAL '60' MONTH,'YYYYMM') AND TO_CHAR(SYSDATE,'YYYYMM')	-- 1,877,723
			) S001
		ON  B00H.CRE_YYMM = S001.BASIS_YYMM		-- [B00H]	AutoNumberHASh128(CRE_YYMM, VAAT_CO_CD, FIRM_CD, SVC_RQ_SN, VPNO) AS KEY_PK
		AND B00H.VAAT_CO_CD = S001.VAAT_CO_CD	-- [S001]	Exists(KEY_PK, AutoNumberHASh128(BASIS_YYMM, VAAT_CO_CD, FIRM_CD, SVC_RQ_SN, VPNO)) 
		AND B00H.SVC_RQ_SN = S001.SVC_RQ_SN
		AND B00H.VPNO = S001.VPNO
		AND B00H.FIRM_CD = S001.FIRM_CD
		INNER JOIN (	-- 구매트리
			SELECT
				  BASIS_YYMM -- AS 생성년월
				, VAAT_CO_CD -- AS 법인코드 
				, FIRM_CD -- AS 업체코드 
				, SUPI_PART_FIRM_CD
				, SUPI_VPNO
				, LRNK_PART_FIRM_CD
				, LRNK_VPNO -- AS SUB품번
				, DATA_SN
				, SVC_RQ_SN -- AS 요청번호 
				, VPNO -- AS END품번
				, ROW_SN
				, PART_NM -- AS SUB품명
			FROM GPOSADM.TABLE4		/* 구매원가 Tree 정보 */		-- 773,810,061
			WHERE BASIS_YYMM BETWEEN TO_CHAR(SYSDATE - INTERVAL '60' MONTH,'YYYYMM') AND TO_CHAR(SYSDATE,'YYYYMM')	-- 28,739,995
			) P002
		ON  B00H.CRE_YYMM = P002.BASIS_YYMM		-- [B00H]	AutoNumberHASh128(CRE_YYMM, VAAT_CO_CD, FIRM_CD, SVC_RQ_SN, VPNO) AS KEY_PK
		AND B00H.VAAT_CO_CD = P002.VAAT_CO_CD 	-- [P002]	Exists(KEY_PK, AutoNumberHASh128(BASIS_YYMM, VAAT_CO_CD, FIRM_CD, SVC_RQ_SN, VPNO)) 
		AND B00H.FIRM_CD = P002.FIRM_CD
		AND B00H.SVC_RQ_SN = P002.SVC_RQ_SN
		AND B00H.VPNO = P002.VPNO
		INNER JOIN (	-- 구매스트럭쳐
			SELECT
				  BASIS_YYMM -- AS 생성년월
				, VAAT_CO_CD -- AS 법인코드  
				, FIRM_CD -- AS 업체코드  
				, SUPI_PART_FIRM_CD
				, SUPI_VPNO
				, LRNK_PART_FIRM_CD
				, LRNK_VPNO
				, DATA_SN
				, SIM_MDUL_SN
			FROM GPOSADM.TABLE5		/* 구매원가 Structure정보 */		-- 614,578,506
			WHERE BASIS_YYMM BETWEEN TO_CHAR(SYSDATE - INTERVAL '60' MONTH,'YYYYMM') AND TO_CHAR(SYSDATE,'YYYYMM')	-- 23,476,588
			) P001
		ON  P002.BASIS_YYMM = P001.BASIS_YYMM	-- [P002]	AutoNumberHASh128(BASIS_YYMM, VAAT_CO_CD, FIRM_CD, SUPI_PART_FIRM_CD, SUPI_VPNO, LRNK_PART_FIRM_CD, LRNK_VPNO, DATA_SN) AS KEY_ALT1
		AND P002.VAAT_CO_CD = P001.VAAT_CO_CD	-- [P001]	Exists(KEY_ALT1, AutoNumberHASh128(BASIS_YYMM, VAAT_CO_CD, FIRM_CD, SUPI_PART_FIRM_CD, SUPI_VPNO, LRNK_PART_FIRM_CD, LRNK_VPNO, DATA_SN))
		AND P002.FIRM_CD = P001.FIRM_CD
		AND P002.SUPI_PART_FIRM_CD = P001.SUPI_PART_FIRM_CD
		AND P002.SUPI_VPNO = P001.SUPI_VPNO
		AND P002.LRNK_PART_FIRM_CD = P001.LRNK_PART_FIRM_CD
		AND P002.LRNK_VPNO = P001.LRNK_VPNO
		AND P002.DATA_SN = P001.DATA_SN
		INNER JOIN(		-- SUB 집계
			SELECT
				  BASIS_YYMM -- AS 생성년월
				, VAAT_CO_CD -- AS 법인코드  
				, SVC_RQ_SN -- AS 요청번호 
				, VPNO -- AS END품번
				, FIRM_CD -- AS 업체코드
				, ROW_SN
				, CASE WHEN BZTC_TYPE_CD IN ('2','3') 
				  THEN 'Y' 
				  ELSE 'N' 
				  END AS BZTC_TYPE_CD -- AS 직거래사급여부
				, SIM_MDUL_PART_AMT -- AS 외주재관비        
				, SAPT_UNP -- AS SUB단가
				, STUF_GRSS_CST_AMT -- AS 재료총원가
				, MFR_GRSS_CST_AMT -- AS 가공총원가
				, ETC_GRSS_CST_AMT -- AS 기타비
				, MEMU_RDMP_EXP -- AS 금형상각비
				, APPW2_QTY
			--	, SUM(APPW2_QTY) AS APPW2_QTY --U/S 
			FROM GPOSADM.TABLE7		/* 구매원가 SUB PART 집계 */		-- 779,245,752
			WHERE BASIS_YYMM BETWEEN TO_CHAR(SYSDATE - INTERVAL '60' MONTH,'YYYYMM') AND TO_CHAR(SYSDATE,'YYYYMM')	-- 28,739,407
			) S003
		ON  P002.BASIS_YYMM = S003.BASIS_YYMM	-- [P002]	AutoNumberHASh128(BASIS_YYMM, VAAT_CO_CD, SVC_RQ_SN, VPNO, FIRM_CD, ROW_SN) AS KEY_ALT2
		AND P002.VAAT_CO_CD = S003.VAAT_CO_CD	-- [S003]	Exists(KEY_ALT2, AutoNumberHASh128(BASIS_YYMM, VAAT_CO_CD, SVC_RQ_SN, VPNO, FIRM_CD, ROW_SN))
		AND P002.FIRM_CD = S003.FIRM_CD
		AND P002.SVC_RQ_SN = S003.SVC_RQ_SN
		AND P002.VPNO = S003.VPNO
		AND P002.ROW_SN = S003.ROW_SN
		LEFT JOIN(		-- 직거래 사급
			SELECT
				  BASIS_YYMM -- AS 생성년월
				, VAAT_CO_CD -- AS 법인코드  
				, FIRM_CD -- AS 업체코드 
				, LRNK_PART_FIRM_CD
				, LRNK_VPNO
				, SIM_MDUL_SN
				, SIM_PART_FIRM_CD -- AS 직거래업체코드
				, SIM_MDUL_PART_AMT -- AS 직거래사급단가 
			FROM GPOSADM.TABLE8		/* 구매원가유사모듈단가정보 */		-- 3,320,288
			WHERE BASIS_YYMM BETWEEN TO_CHAR(SYSDATE - INTERVAL '60' MONTH,'YYYYMM') AND TO_CHAR(SYSDATE,'YYYYMM')	-- 143,187
			) P010
		ON  P001.BASIS_YYMM = P010.BASIS_YYMM	-- [P001]	AutoNumberHASh128(BASIS_YYMM, VAAT_CO_CD, FIRM_CD, LRNK_PART_FIRM_CD, LRNK_VPNO, SIM_MDUL_SN) AS KEY_ALT3	
		AND P001.VAAT_CO_CD = P010.VAAT_CO_CD	-- [P010]	Exists(KEY_ALT3, AutoNumberHASh128(BASIS_YYMM, VAAT_CO_CD, FIRM_CD, LRNK_PART_FIRM_CD, LRNK_VPNO, SIM_MDUL_SN))
		AND P001.FIRM_CD = P010.FIRM_CD
		AND P001.LRNK_PART_FIRM_CD = P010.LRNK_PART_FIRM_CD
		AND P001.LRNK_VPNO = P010.LRNK_VPNO
		AND P001.SIM_MDUL_SN = P010.SIM_MDUL_SN
		) Temp_T
	GROUP BY 
		  생성년월
		, 법인코드 
		, 업체코드 
		, 요청번호 
		, END품번
		, END품명
		, 단가
		, SUB품번
		, SUB품명
		, 직거래사급여부
		, 직거래업체코드
		, 직거래사급단가
		, 외주재관비
		, SUB단가
		, 재료총원가
		, 가공총원가
		, 기타비
		, 금형상각비
	) Summary
/*------------------------------------ Dimension ---------------------------------*/
LEFT JOIN (
	SELECT 
		  VEND_CD -- AS 업체코드
		, VEND_NM AS 업체명
	FROM 업체마스터
	) 업체정보
ON Summary.업체코드 = 업체정보.VEND_CD	-- Exists(업체코드, VEND_CD)
LEFT JOIN (
	SELECT 
		  VEND_CD -- AS 직거래업체코드
		, VEND_NM AS 직거래업체명
	FROM 업체마스터
	) 직거래업체정보
ON Summary.직거래업체코드 = 직거래업체정보.VEND_CD	-- Exists(직거래업체코드, VEND_CD)
