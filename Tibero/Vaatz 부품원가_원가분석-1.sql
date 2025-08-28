-- Vaatz 부품원가_원가분석-1 

/* 작성자 : 이소진
 * 작업내역 : 2025.05.13 최초 작성
 * 
 * DB Connection : GPOSADM_VER
 * 
 * [Target/Source 앱]
 * Vaatz_변경적재(부품원가)_NEW
 * Vaatz_변경적재(마스터外)_NEW2
 * 
 * [Fact Table]
 * TABLE1	변동대상헤더
 * TABLE2	원가내역 요청마스터(1, 2, 4) - Subpart 확정( 1
 * TABLE3	구매원가 END ITEM 집계
 * 
 * [Master Table]
 * TABLE4	*업체마스터
 * 
 * */

/*------------------------------ Main ~ Allocation ------------------------------*/
SELECT
	   F."ProcDate"
	 , F.VAAT_CO_CD
	 , F.SVC_RQ_SN  --요청번호
	 , F.VPNO       --End품번
	 , F.FIRM_CD    --업체코드
	 , F.VAAT_CNSU_NO --품의번호
	 , F.PART_NM   --End품명
	 , F.PUR_OPS_NM  --팀	
	 , F.PUR_CRGR_NM --담당자
	 , F.PUR_UNP_APL_YMD --적용일  
	 , F.CURR_CD --통화
	 , F.RQ_EO_NO --EONO	
	 , F.VEHL_MDY_CD --차종	
	 , F.DTRM_PCE --단가
	 , F.SUM_CNT
	 , M.VEND_TYPE
	 , M.VEND_NM_EXT
	 , M.VEND_NM_ENG
	 , M.VEND_CTRY_CD
	 , M.REPR_NM_EXT
FROM (
	SELECT
		   TO_DATE(B00H."ProcDate",'YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		 , B00H.VAAT_CO_CD
		 , B00H.SVC_RQ_SN  --요청번호
		 , B00H.VPNO       --End품번
		 , B00H.FIRM_CD    --업체코드
		 , B00H.VAAT_CNSU_NO --품의번호
		 , B00H.PART_NM   --End품명
		 , B00H.PUR_OPS_NM  --팀	
		 , B00H.PUR_CRGR_NM --담당자
		 , B00H.PUR_UNP_APL_YMD --적용일  
		 , R002.CURR_CD --통화
		 , R002.RQ_EO_NO --EONO	
		 , R002.VEHL_MDY_CD --차종	
		 , S001.DTRM_PCE --단가
		 , 1 AS SUM_CNT
	FROM (
		SELECT
			  ORA_HASH(CRE_YYMM || VAAT_CO_CD || SVC_RQ_SN || VPNO || FIRM_CD) AS PK_KEY
			, CRE_YYMM    --년월
			, CRE_YYMM || '01' AS "ProcDate"
			, VAAT_CO_CD --회사코드 
			, TO_CHAR(SVC_RQ_SN) AS SVC_RQ_SN  --요청번호
			, VPNO       --End품번
			, FIRM_CD    --업체코드
			, VAAT_CNSU_NO --품의번호
			, PART_NM   --End품명
			, PUR_OPS_NM  --팀	
			, PUR_CRGR_NM --담당자
			, TO_DATE(PUR_UNP_APL_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS PUR_UNP_APL_YMD	--적용일    -- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		FROM GPOSADM.TABLE1	/* 변동대상헤더 */		-- 91,114,530
		WHERE CRE_YYMM
			BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -60),'YYYYMM') 	-- 최근 5년
			AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR,'YYYYMM')		-- 48,453,177
	) AS B00H
	INNER JOIN (
		SELECT
			  ORA_HASH(BASIS_YYMM || VAAT_CO_CD || SVC_RQ_SN || VPNO || FIRM_CD) AS PK_KEY
			, BASIS_YYMM
			, BASIS_YYMM || '01' AS "ProcDate" 
			, VAAT_CO_CD
			, TO_CHAR(SVC_RQ_SN) AS SVC_RQ_SN
			, VPNO
			, FIRM_CD
			, CURR_CD --통화
			, RQ_EO_NO --EONO	
			, VEHL_MDY_CD --차종	
		FROM GPOSADM.TABLE2	/* 원가내역 요청마스터(1, 2, 4) - Subpart 확정( 1 */		-- 50,563,735
		WHERE BASIS_YYMM
			BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -60),'YYYYMM') 	-- 최근 5년
			AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR,'YYYYMM')		-- 49,353,938
		) R002
	ON  B00H.CRE_YYMM = R002.BASIS_YYMM
	AND B00H.VAAT_CO_CD = R002.VAAT_CO_CD
	AND B00H.SVC_RQ_SN = R002.SVC_RQ_SN
	AND B00H.VPNO = R002.VPNO
	AND B00H.FIRM_CD = R002.FIRM_CD
	INNER JOIN(
		SELECT
			  BASIS_YYMM
			, BASIS_YYMM || '01' AS "ProcDate" 
			, VAAT_CO_CD
			, TO_CHAR(SVC_RQ_SN) AS SVC_RQ_SN
			, VPNO
			, FIRM_CD
			, DTRM_PCE --단가
		FROM GPOSADM.TABLE3	/* 구매원가 END ITEM 집계 */		-- 48,061,742
		WHERE BASIS_YYMM
			BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -60),'YYYYMM') 	-- 최근 5년
			AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR,'YYYYMM')		-- 47,453,521
	) S001
	ON  B00H.CRE_YYMM = S001.BASIS_YYMM
	AND B00H.VAAT_CO_CD = S001.VAAT_CO_CD
	AND B00H.SVC_RQ_SN = S001.SVC_RQ_SN
	AND B00H.VPNO = S001.VPNO
	AND B00H.FIRM_CD = S001.FIRM_CD
) F
/*---------------------------------- Dimension ----------------------------------*/
LEFT JOIN (
	SELECT
		   VAAT_CO_CD
		 , VEND_CD
		 , VEND_TYPE
		 , VEND_NM_EXT
		 , VEND_NM_ENG
		 , VEND_CTRY_CD
		 , REPR_NM_EXT
	FROM GPOSADM.TABLE4	/* *업체마스터 */
	) M
ON  F.VAAT_CO_CD = M.VAAT_CO_CD
AND F.FIRM_CD = M.VEND_CD

