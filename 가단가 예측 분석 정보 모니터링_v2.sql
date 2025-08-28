-- 가단가 예측 분석 정보 모니터링_v2

/* 작성자 : 이소진
 * 작업내역 : 2025.05.21 최초 작성
 * 
 * DB Connection : GPOSADM_VER
 * 
 * [Target/Source 앱]
 * Vaatz_변경적재(가격관리)
 * Vaatz_변경적재(마스터外)_NEW2 (TABLE3 > TDWMA_MSTCARCD 참고)
 * 
 * [Table]
 * TABLE1	개발요청가단가정보
 * TABLE2
 * TABLE3	차종코드마스터
 * TABLE4	*사용자관리마스터
 * TABLE5	*부서코드
 *  
 * */

/*----------------------------TABLE1PIMDWXUPA ---------------------------*/
SELECT 
	  PIMD.VAAT_CORP_CD AS "VPIMADM/TABLE1.법인"
	, PIMD.VPNO AS "VPIMADM/TABLE1.품번"	
	, PIMD.FIRM_CD AS 가단가업체
	, PIMD.PUR_UNP_APL_YMD AS 가단가적용일
	, PIMD.PUR_UNP AS 가단가
	, PIMD.BZTC_CURR_CD AS 화폐
	, PIMD.PART_NM AS 품명
	, PIMD.PUR_DCD AS "가단가팀-팀"
	, PIMD.PUR_CRGR_ID AS 가단가등록자
	, TO_DATE(PIMD.INP_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS 가단가입력일		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, TO_DATE(PIMD.ACT_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS 가단가조치일		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, PIMD.VAAT_CNSU_NO AS 가단가품의서
	, PIMD.ACT_SCN_CD AS 조치구분
	, PIMD.WK_SN AS 가단가순번
	, PIMD.PRE_PNO AS 종전품번
	, PIMD.PRE_PUR_UNP AS 종전품번종전가
--	, PIMP.VAAT_CORP_CD AS "VPIMADM/TABLE2.법인"
	, PIMP.VPNO AS 품번
	, PIMP.COMP_PTNO AS 품번_10자리
	, PIMP.CARS_C AS 차종
	, PIMP.YEAR_C AS 년식
	, PIMP.CARS_G_CD AS 차급
	, PIMP.UPGO_NO AS UPG
	, PIMP.UPGO_VC AS VC
	, PIMP.OPTI_CO AS OPT
	, PIMP.RQ_SCN_CD AS 요청구분
	, PIMP.EST_SCN_RATIO AS 예측정도
	, PIMP.PUR_UNP AS 예측가
	, PIMP.AVG_UNP AS 평균가
	, PIMP.OPTI_UNP AS 옵션예상가
	, TO_DATE(PIMP.EST_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS 산출일		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, PIMP.FIRST_UNP AS 초도가
	, PIMP.FIRST_FIRM_CD AS 초도가업체
	, PIMP.FIRST_VPNO AS 초도가품번
	, PIMP.FIRST_UNP_NOS AS 초도가차수
	, TO_DATE(PIMP.FIRST_UNP_APL_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS 초도가등록일	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, TO_DATE(PIMP.FIN_MDFY_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS 최종수정일				-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, PIMP.DCD AS 초도가등록팀
	, PIMP.CRGR_ID AS 초도가등록자
	, PIMP.MDL_SCN_CD AS 차종구분
	, PIMP.VAAT_CO_CD AS 회사
	, PIMP.VEHL_NM AS 차종_영문명
	, PIMP.RGST_TIM + INTERVAL '9' HOUR AS RGST_TIM		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, PIMP.MDL_NO AS 모델NO
	, PIMP.MDL_FP_CD AS 모델코드
	, PIMP.PJT_CD AS 프로젝트코드
	, PIMP.VEHL_REPN_CD_NM AS 차종명
	, TO_DATE(PIMP.APL_CRTN_YMD, 'YYYYMMDD') + INTERVAL '9' HOUR AS APL_CRTN_YMD		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, PIMP.FNH_YMD
	, PIMP._SAT_TABLE3
	, PIMP._CNT_TABLE3	
	, PIMP."차종_M-년식_M-차종-년식"
	, MSTU.VAAT_CO_CD AS 법인명
	, MSTU.USER_ID AS 사번
	, MSTU.VAAT_CORP_CD AS 법인_U
	, MSTU.USER_NM_EXT AS 담당명
	, MSTU.USER_NM_ENG AS 담당명_영문
	, MSTU.DEPT_CD AS 팀코드
	, MSTU.EMAIL
	, MSTU.USE_ST_CD AS 상태
	, MSTD.VAAT_CO_CD AS 회사_U
	, MSTD.OPS_NM AS 팀명
	, MSTD.USE_YN AS 사용여부
	, MSTD.USE_ST_CD AS "상태_팀정보"
	, MSTD.UP_DEPT_CD AS 상위부서
FROM GPOSADM.TABLE1 PIMD	/* 개발요청가단가정보 */
/*---------------------------- VPIMADM/TABLE2 ---------------------------*/
LEFT JOIN (
	SELECT 
		  T1.VAAT_CORP_CD -- AS "VPIMADM/TABLE2.법인"
		, T1.VPNO -- AS 품번
		, T1.COMP_PTNO -- AS 품번_10자리
		, T1.CARS_C -- AS 차종
		, T1.YEAR_C -- AS 년식
		, T1.CARS_G_CD -- AS 차급
		, T1.UPGO_NO -- AS UPG
		, T1.UPGO_VC -- AS VC
		, T1.OPTI_CO -- AS OPT
		, T1.RQ_SCN_CD -- AS 요청구분
		, T1.EST_SCN_RATIO -- AS 예측정도
		, T1.PUR_UNP -- AS 예측가
		, T1.AVG_UNP -- AS 평균가
		, T1.OPTI_UNP -- AS 옵션예상가
		, T1.EST_YMD
		, T1.FIRST_UNP -- AS 초도가
		, T1.FIRST_FIRM_CD -- AS 초도가업체
		, T1.FIRST_VPNO -- AS 초도가품번
		, T1.FIRST_UNP_NOS -- AS 초도가차수
		, T1.FIRST_UNP_APL_YMD
		, T1.FIN_MDFY_YMD
		, T1.DCD -- AS 초도가등록팀
		, T1.CRGR_ID -- AS 초도가등록자
		, T1.CARS_C || T1.YEAR_C AS "차종_M-년식_M-차종-년식"
	--	, T2.VEHL_REPN_CD AS 차종_M
	--	, T2.Y_SCN_CD AS 년식_M
		, T2.MDL_SCN_CD -- AS 차종구분
		, T2.VAAT_CO_CD -- AS 회사
		, T2.VEHL_NM -- AS 차종_영문명
		, T2.RGST_TIM
		, T2.MDL_NO -- AS 모델NO
		, T2.MDL_FP_CD -- AS 모델코드
		, T2.PJT_CD -- AS 프로젝트코드
		, T2.VEHL_REPN_CD_NM -- AS 차종명
		, T2.APL_CRTN_YMD
		, T2.FNH_YMD
		, T2._SAT_TABLE3
		, T2._CNT_TABLE3		
	FROM GPOSADM.TABLE2 T1
	LEFT JOIN (
		SELECT
			  VEHL_REPN_CD -- AS 차종_M
			, Y_SCN_CD -- AS 년식_M
			, MDL_SCN_CD -- AS 차종구분
			, VAAT_CO_CD -- AS 회사
			, VEHL_NM -- AS 차종_영문명
			, RGST_TIM
			, MDL_NO -- AS 모델NO
			, MDL_FP_CD -- AS 모델코드
			, PJT_CD -- AS 프로젝트코드
			, VEHL_REPN_CD_NM -- AS 차종명
			, APL_CRTN_YMD
			, FNH_YMD
			, USE_ST_CD AS _SAT_TABLE3
			, 1 AS _CNT_TABLE3
		FROM GPOSADM.TABLE3	/* 차종코드마스터 */
		) T2
	ON  T1.CARS_C = T2.VEHL_REPN_CD		-- [TABLE2]	CARS_C & YEAR_C AS 차종_M-년식_M-차종-년식
	AND T1.YEAR_C = T2.Y_SCN_CD			-- [TABLE3]		VEHL_REPN_CD & Y_SCN_CD AS 차종_M-년식_M-차종-년식
	) PIMP
ON  PIMD.VAAT_CORP_CD = PIMP.VAAT_CORP_CD	-- [PIMD]	VAAT_CORP_CD & VPNO AS 법인_품번
AND PIMD.VPNO = PIMP.VPNO					-- [PIMP]	VAAT_CORP_CD & VPNO AS 법인_품번
/*---------------------------- VMSTADM/TABLE4 ----------------------------*/
LEFT JOIN (
	SELECT 
		  VAAT_CO_CD -- AS 법인명
		, USER_ID -- AS 사번
		, VAAT_CORP_CD -- AS 법인_U
		, USER_NM_EXT -- AS 담당명
		, USER_NM_ENG -- AS 담당명_영문
		, DEPT_CD -- AS 팀코드
		, EMAIL
		, USE_ST_CD -- AS 상태
	FROM GPOSADM.TABLE4		/* *사용자관리마스터 */
	) MSTU
ON  PIMD.VAAT_CORP_CD = MSTU.VAAT_CORP_CD	-- [PIMD]	VAAT_CORP_CD & PUR_CRGR_ID AS 법인_사번
AND PIMD.PUR_CRGR_ID = MSTU.USER_ID			-- [MSTU]	VAAT_CORP_CD & USER_ID AS 법인_사번
/*---------------------------- VMSTADM/TABLE5 ----------------------------*/
LEFT JOIN (
	SELECT
		  VAAT_CO_CD -- AS 회사_U
		, OPS_NM -- AS 팀명
		, USE_YN -- AS 사용여부
		, USE_ST_CD -- AS "상태_팀정보"
		, DEPT_CD -- AS "가단가팀-팀"
		, UP_DEPT_CD -- AS 상위부서
	FROM GPOSADM.TABLE5		/* *부서코드 */
	) MSTD
ON  PIMD.PUR_DCD = MSTD.DEPT_CD			-- [PIMD]	PUR_DCD AS "가단가팀-팀"
										-- [MSTD]	DEPT_CD AS "가단가팀-팀"

