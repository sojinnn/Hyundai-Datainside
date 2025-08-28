-- Vaatz 가격관리_단가조회(대상품번Upload)

/* 작성자 : 이소진
 * 작업내역 : 2025.05.23 최초 작성
 * 
 * DB Connection : GPOSADM_VER
 * 
 * [Target/Source 앱]
 * Vaatz_변경적재(가격관리) 
 * Vaatz_변경적재(마스터外)_NEW2
 * 
 * [Table]
 * TABLE1		품의서마스터
 * TABLE2		품의서마스터
 * TABLE3		국내생산부품단가마스터
 * TABLE4		국내생산부품단가마스터 최종차수 
 * TABLE5		생산부품외자단가마스터
 * TABLE6		생산부품외자단가마스터 최종차수
 * TABLE7		해외생산자재단가마스터
 * TABLE8		해외생산자재단가마스터 최종차수
 * TABLE9		해외AS400가격품의서정보
 * TABLE10		해외ERP가격품의서정보
 * TABLE11		해외ERP가격품의서정보
 * TABLE12		해외ERP가격품의서정보
 * TABLE13		상세코드마스터
 * TABLE14		가격품의정산조건정보
 * TABLE15		가격품의정산조건정보
 * TABLE16		*업체마스터
 * TABLE17		*부서코드
 * TABLE18
 * TABLE19 
 *  
 * */

WITH TABLE1 AS (
	SELECT
		  VAAT_CORP_CD    -- 관리법인
		, CL_SCN_CD
		, VAAT_CNSU_NO
--		, CO_SCN_CD
--		, DMSD_XPO_SCN_CD
--		, INP_YMD
--		, FIRM_CD
--		, RDCS_YN
--		, RDCS_YMD
--		, CACT1_YMD
--		, ACT_SCN_CD
		, DVLP_DCD          -- 담당부서코드
--		, NCAR_MDL_CD
--		, NCAR_VEHL_NM
		, PPRR_ID           -- 담당자 사번
		, PPRR_NM           -- 담당자
--		, BZTC_CURR_CD
--		, TH1_RDCS_YMD
--		, SLIP_YMD
--		, ACTR_ID
--		, AT_JRNL_YN
--		, RGST_RSON_SBC
--		, APAU1_CD
--		, STOA_SCN_CD
--		, VAAT_PLNT_CD
--		, IF_TYPE_CD
--		, USE_YN
--		, ATTC_YN
--		, FIN_MDFY_YMD
--		, PLN_PRDN_CRT
--		, PART_PUR_AMT
--		, CSUS_TITL_NM
--		, CSVA_XPRT_YYC
--		, TYPE_EFF_AMT
--		, GRSS_MEMU_EXP
--		, VAL_SCN_CD
--		, CNSU_TH1_VEHL_CD
--		, CNSU_TH2_VEHL_CD
--		, CNSU_TH3_VEHL_CD
--		, CNSU_TH4_VEHL_CD
--		, CNSU_TH5_VEHL_CD
--		, PRDN_PLN_CRT_SBC
		, LDC_RT               -- ldc율
		, CRTN_XR              -- 기준환율
--		, DLG_CRTN_SBC
--		, RDCS_CRTN_SBC
--		, ITG_RANK_FIRM_CD
--		, CURR_CD
--		, ET_YMD
--		, ET_CTMS
--		, PCE_CRTN_CD
--		, AT_PART_PUR_AMT
--		, AT_TYPE_EFF_AMT
--		, REFL_YN
--		, K_ET_YMD
--		, FCLT_SCN_YN
--		, TH2_ATTC_YN
--		, TL_NO
--		, TH3_ATTC_YN
--		, WHSN_FIRM_CD
--		, FCLT_SCN_YN_2
--		, MEMU_CL_CD
--		, CON_ATTC_YN
--		, TH1_CUR_XR
--		, TH1_ALTR_XR
--		, TH2_CUR_XR
--		, TH2_ALTR_XR
--		, TH3_CUR_XR
--		, TH3_ALTR_XR
--		, XR_APL_Y
--		, XR_ALTR_SN
--		, PCAR_EFF_AMT
--		, XR_CRTN_APL_Y
--		, TH1_CRTN_XR
--		, TH2_CRTN_XR
--		, TH3_CRTN_XR
--		, EST_RQST_NO
--		, VAAT_ELEC_CNTT_NO
--		, VAAT_ELEC_ACT_CD
--		, BATH_YYMM
--		, BATHSERI
--		, TH4_ATTC_YN
--		, K_VAAT_ELEC_CNTT_NO
--		, K_VAAT_ELEC_ACT_CD
--		, CSUS_COMP_SBC
--		, PRJ_SCN_CD
--		, PRJ_UNP_NOS
--		, MSSY_YMD
--		, ETL_LOAD_DATE
	FROM GPOSADM.TABLE1		/* 품의서마스터 */		-- 12,238,874
	WHERE 1=1
		AND VAAT_CORP_CD = 'K1'
	),
TABLE2 AS (
	SELECT
		  VAAT_CORP_CD                 -- 관리법인
	--	, CL_SCN_CD
		, VAAT_CNSU_NO                 -- 품의번호
	--	, CO_SCN_CD
	--	, DMSD_XPO_SCN_CD
	--	, INP_YMD
	--	, FIRM_CD
	--	, RDCS_YN
	--	, RDCS_YMD
	--	, ACT_SCN_CD
		, DVLP_DCD                       -- 담당부서코드
	--	, NCAR_MDL_CD
	--	, NCAR_VEHL_NM
		, PPRR_ID                        -- 담당자사번 
		, PPRR_NM                        -- 담당자
	--	, BZTC_CURR_CD
	--	, AT_JRNL_YN
	--	, APAU1_CD
	--	, STOA_SCN_CD
	--	, VAAT_PLNT_CD
	--	, IF_TYPE_CD
	--	, USE_YN
	--	, ATTC_YN
	--	, FIN_MDFY_YMD
	--	, PLN_PRDN_CRT
	--	, PART_PUR_AMT
	--	, CSUS_TITL_NM
	--	, CSVA_XPRT_YYC
	--	, TYPE_EFF_AMT
	--	, GRSS_MEMU_EXP
	--	, VAL_SCN_CD
	--	, CNSU_TH1_VEHL_CD
	--	, CNSU_TH2_VEHL_CD
	--	, CNSU_TH3_VEHL_CD
	--	, CNSU_TH4_VEHL_CD
	--	, CNSU_TH5_VEHL_CD
	--	, PRDN_PLN_CRT_SBC
		, LDC_RT                       -- LDC율
		, CRTN_XR                      -- 기준환율
	--	, DLG_CRTN_SBC
	--	, RDCS_CRTN_SBC
	--	, ITG_RANK_FIRM_CD
	--	, PCE_CRTN_CD
	--	, PUR_ET_YN
	--	, ET_YMD
	--	, AT_PART_PUR_AMT
	--	, AT_TYPE_EFF_AMT
	--	, REFL_YN
	--	, TR_BZTC_CURR_CD
	--	, EST_RQST_NO
	--	, ETL_LOAD_DATE
	FROM GPOSADM.TABLE2		/* 품의서마스터 */		-- 235,848
	WHERE CL_SCN_CD = 'P'
	),
/*========================================================================
								Fact_K1
========================================================================*/
Fact_K1 AS (
	SELECT 
		  T1.AREA
		, T1.AREA_GUBUN
		, T1.VPNO				-- 품번
		, T1.FIRM_CD			-- 업체코드
		, T1.UNP_NOS			-- 차수
		, T1.PUR_UNP_APL_YMD	-- 적용시점
		, TO_DATE(T1.PUR_UNP_APL_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, T1.CSDY_AMT		-- 관세
		, T1.PUR_UNP		-- 가격
		, T1.BZTC_CURR_CD	-- 통화
		, T1.PRICE_UNIT
		, T1.VAAT_CNSU_NO	-- 품의번호
		, T1.QEXP			-- 서열비
		, T3.VAAT_CORP_CD	-- 관리법인
		, T3.DVLP_DCD		-- 담당부서코드
		, T3.PPRR_ID		-- 담당자 사번
		, T3.PPRR_NM		-- 담당자
		, T3.LDC_RT			-- ldc율
		, T3.CRTN_XR		-- 기준환율
	FROM (
		SELECT
			  '국내' AS AREA
			, '01' AS AREA_GUBUN
			, VPNO						--품번
			, FIRM_CD					--업체코드
			, UNP_NOS					--차수
		--	, DMSD_XPO_SCN_CD
		--	, INP_YMD
		--	, PUR_UNP_APL_YMD			--적용시점
			, CASE WHEN REGEXP_LIKE(PUR_UNP_APL_YMD, '^[0-9]{8}$') 
				   THEN 
						CASE WHEN	( SUBSTR(PUR_UNP_APL_YMD,5,2) IN (1,3,5,7,8,10,12) AND SUBSTR(PUR_UNP_APL_YMD,7,2) BETWEEN '01' AND '31' )
								OR	( SUBSTR(PUR_UNP_APL_YMD,5,2) IN (4,6,9,11) AND SUBSTR(PUR_UNP_APL_YMD,7,2) BETWEEN '01' AND '30' )
								OR	( SUBSTR(PUR_UNP_APL_YMD,5,2) = '02' AND SUBSTR(PUR_UNP_APL_YMD,7,2) BETWEEN '01' AND '29' )
							 THEN PUR_UNP_APL_YMD
							 END
				   END AS PUR_UNP_APL_YMD		-- 이상값 Null로 치환
			, CSDY_AMT					--관세
		--	, USE_YN
		--	, PCE_SCN_CD
			, PUR_UNP					--가격
		--	, PRE_PUR_UNP
		--	, MEMU_PFNS_YN
		--	, PUSR1_CD
		--	, VAAT_CNSU_NO
		--	, CO_SCN_CD
			, BZTC_CURR_CD				--통화
			, 1 AS PRICE_UNIT
		--	, FIN_MDFY_YMD
		--	, ET_YMD
		--	, ET_CTMS
		--	, BID_IG_NO
		--	, TH1_VAAT_CNSU_NO
			, CASE WHEN TH2_VAAT_CNSU_NO IS NULL
			  THEN TH1_VAAT_CNSU_NO
			  ELSE TH2_VAAT_CNSU_NO
			  END AS VAAT_CNSU_NO		--품의번호
		--	, AT_JRNL_YN
		--	, ETL_SELECT_DATE
			, QEXP						--서열비
		FROM GPOSADM.TABLE3	/* 국내생산부품단가마스터 */		-- 167,557,191
		WHERE PUR_UNP_APL_YMD BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -61), 'YYYYMMDD') 	-- 최근 5년
							  AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMMDD')		-- 62,074,998
		) T1
	INNER JOIN (			
		SELECT
			  VPNO
			, FIRM_CD
			, UNP_NOS
		FROM GPOSADM.TABLE4	/* 국내생산부품단가마스터 최종차수 */	-- 12,238,874
		) T2
	ON  T1.VPNO = T2.VPNO
	AND T1.FIRM_CD = T2.FIRM_CD
	AND T1.UNP_NOS = T2.UNP_NOS
	INNER JOIN (
		SELECT
			  VAAT_CORP_CD		--관리법인
			, VAAT_CNSU_NO
			, DVLP_DCD			--담당부서코드
			, PPRR_ID			--담당자 사번
			, PPRR_NM			--담당자
			, LDC_RT			--ldc율
			, CRTN_XR			--기준환율
		FROM TABLE1
		WHERE CL_SCN_CD = 'P'
		) T3
	ON T1.VAAT_CNSU_NO = T3.VAAT_CNSU_NO
	),
/*========================================================================
								Fact_K2
========================================================================*/
Fact_K2 AS (
	SELECT 
		  T1.*
		, T3.VAAT_CORP_CD	-- 관리법인
		, T3.DVLP_DCD		-- 담당부서코드
		, T3.PPRR_ID		-- 담당자 사번
		, T3.PPRR_NM		-- 담당자
		, T3.LDC_RT			-- ldc율
		, T3.CRTN_XR		-- 기준환율
	FROM (
		SELECT
			  '국내' AS AREA
			, '02' AS AREA_GUBUN
		--	, VAAT_CORP_CD
			, VPNO                                  -- 품번
			, FIRM_CD                               -- 업체코드
			, UNP_NOS                               -- 차수
		--	, INP_YMD
			, PCE_APL_STRT_YMD AS PUR_UNP_APL_YMD	-- 적용시점
			, TO_DATE(PCE_APL_STRT_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		--	, PCE_APL_FNH_YMD
			, 0 AS CSDY_AMT    						-- 관세
			, PUR_UNP								-- 가격
			, BZTC_CURR_CD							-- 통화
		--	, PRE_PUR_UNP
			, 1 AS PRICE_UNIT				
		--	, REGN_CD
		--	, PART_NM
		--	, FIRM_PART_NO
		--	, PUR_UTM_CD
		--	, VAAT_CO_SCN_CD
		--	, ERP_PLNT_CD
		--	, APL_REGN_CD
		--	, STD_UNP
			, VAAT_CNSU_NO                          -- 품의번호
		--	, UNP_STTG_RSON_CD
		--	, MIN_ORDN_QTY
		--	, ORDN_RTO
		--	, UTM_QTY
		--	, LSP_MEMU_EXP
		--	, TH1_AFT_MGMT_CD
		--	, TH2_AFT_MGMT_CD
		--	, TH3_AFT_MGMT_CD
		--	, TH4_AFT_MGMT_CD
		--	, TH5_AFT_MGMT_CD
		--	, FIN_MDFY_YMD
		--	, ET_YMD
		--	, ET_CTMS
		--	, ET_ST_CD
		--	, BID_IG_NO
		--	, USE_YN
		--	, ETL_LOAD_DATE
			, 0 AS QEXP        						-- 서열비		
		FROM GPOSADM.TABLE5	/* 생산부품외자단가마스터 */		-- 54,121
		WHERE PCE_APL_STRT_YMD BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -61), 'YYYYMMDD') 	-- 최근 5년
							   AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMMDD')		-- 27,116
		) T1
	INNER JOIN (
		SELECT
			  VPNO
			, FIRM_CD
			, UNP_NOS
		FROM GPOSADM.TABLE6	/* 생산부품외자단가마스터 최종차수 */	-- 15,119
		) T2
	ON  T1.VPNO = T2.VPNO
	AND T1.FIRM_CD = T2.FIRM_CD
	AND T1.UNP_NOS = T2.UNP_NOS
	INNER JOIN (
		SELECT
			  VAAT_CORP_CD    -- 관리법인
			, VAAT_CNSU_NO
			, DVLP_DCD          -- 담당부서코드
			, PPRR_ID           -- 담당자 사번
			, PPRR_NM           -- 담당자
			, LDC_RT               -- ldc율
			, CRTN_XR              -- 기준환율
		FROM TABLE1
		WHERE CL_SCN_CD = 'E'
		) T3
	ON T1.VAAT_CNSU_NO = T3.VAAT_CNSU_NO
	),
/*========================================================================
								Fact_G_A400
========================================================================*/
Fact_G_A400_Tmp AS (
	SELECT 
		  T1.*
		, T3.DVLP_DCD	-- 담당부서코드
		, T3.PPRR_ID	-- 담당자사번 
		, T3.PPRR_NM	-- 담당자	
		, T3.LDC_RT		-- LDC율
		, T3.CRTN_XR	-- 기준환율
	FROM (
		SELECT 
			  '해외' AS AREA
			, 'A400' AS AREA_GUBUN
			, VAAT_CORP_CD               -- 관리법인
			, VPNO
			, FIRM_CD                    -- 업체코드
			, UNP_NOS                    -- 차수
		--	, DMSD_XPO_SCN_CD
		--	, USE_YN
			, PUR_UNP_APL_YMD            -- 적용시점
			, TO_DATE(PUR_UNP_APL_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		--	, INP_YMD
			, CSDY_AMT                   -- 관세
			, PUR_UNP                    -- 가격
			, BZTC_CURR_CD               -- 통화
			, PCE_APL_QTY AS PRICE_UNIT  -- PRICE_UNIT
		--	, D_CURR_UTM_UNP
		--	, VAAT_PRE_PUR_UNP
		--	, PUSR1_CD
		--	, UNP_DFF_AMT
		--	, T2USR1_CD
		--	, TH2_UNP_DFF_AMT
			, VAAT_CNSU_NO               -- 품의번호
		--	, UTM_QTY
		--	, EO_NO			
		--	, SEND_FLAG
		--	, SEND_DATE			
		--	, FNSH_CURR_CD
		--	, QEXP
		--	, HSN_CD
		--	, ETL_LOAD_DATE
		FROM GPOSADM.TABLE7		/* 해외생산자재단가마스터 */		-- 10,623,770
		WHERE PUR_UNP_APL_YMD BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -61), 'YYYYMMDD') 	-- 최근 5년
							  AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMMDD')		-- 5,713,737
		) T1
	INNER JOIN (
		SELECT
			  VAAT_CORP_CD
			, VPNO
			, FIRM_CD
			, UNP_NOS
		FROM GPOSADM.TABLE8		/* 해외생산자재단가마스터 최종차수 */	-- 758,593
		) T2
	ON  T1.VAAT_CORP_CD = T2.VAAT_CORP_CD
	AND T1.VPNO = T2.VPNO		
	AND T1.FIRM_CD = T2.FIRM_CD	
	AND T1.UNP_NOS = T2.UNP_NOS
	INNER JOIN (
		SELECT
			  VAAT_CORP_CD                 -- 관리법인
			, VAAT_CNSU_NO                 -- 품의번호
			, DVLP_DCD                       -- 담당부서코드
			, PPRR_ID                        -- 담당자사번 
			, PPRR_NM                        -- 담당자
			, LDC_RT                       -- LDC율
			, CRTN_XR                      -- 기준환율
		FROM TABLE2
		) T3
	ON  T1.VAAT_CORP_CD = T3.VAAT_CORP_CD
	AND T1.VAAT_CNSU_NO = T3.VAAT_CNSU_NO
	),
Fact_G_A400 AS (
	SELECT 	  
		  Fact_Tmp.AREA
		, Fact_Tmp.AREA_GUBUN		
		, Fact_Tmp.VPNO
		, Fact_Tmp.FIRM_CD               -- 업체코드
		, Fact_Tmp.UNP_NOS               -- 차수
		, Fact_Tmp.PUR_UNP_APL_YMD       -- 적용시점
		, Fact_Tmp."ProcDate" 			--적용시점
		, Fact_Tmp.CSDY_AMT				-- 관세
		, Fact_Tmp.PUR_UNP               -- 가격
		, Fact_Tmp.BZTC_CURR_CD          -- 통화
		, Fact_Tmp.PRICE_UNIT  			-- PRICE_UNIT
		, Fact_Tmp.VAAT_CNSU_NO          -- 품의번호
		, QEXP_Tmp.QEXP
		, Fact_Tmp.VAAT_CORP_CD          -- 관리법인
		, Fact_Tmp.DVLP_DCD	-- 담당부서코드
		, Fact_Tmp.PPRR_ID	-- 담당자사번 
		, Fact_Tmp.PPRR_NM	-- 담당자	
		, Fact_Tmp.LDC_RT		-- LDC율
		, Fact_Tmp.CRTN_XR	-- 기준환율
	FROM Fact_G_A400_Tmp AS Fact_Tmp
	LEFT JOIN (
		SELECT
			  T1.VAAT_CORP_CD
			, T1.VAAT_CNSU_NO
			, T1.VPNO
			, T1.PUR_UNP_APL_YMD
			, T1.QEXP
		FROM (
			SELECT 
				  VAAT_CORP_CD
				, VAAT_CNSU_NO
				, VPNO
				, PUR_UNP_APL_YMD
				, QEXP
			FROM GPOSADM.TABLE9		/* 해외AS400가격품의서정보 */		-- 4,580,049
			WHERE PUR_UNP_APL_YMD BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -61), 'YYYYMMDD') 	-- 최근 5년
								  AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMMDD')		-- 2,269,194
			) T1
		INNER JOIN Fact_G_A400_Tmp T2
		ON  T1.VAAT_CORP_CD = T2.VAAT_CORP_CD		-- [T1]	VAAT_CORP_CD&'|'&VAAT_CNSU_NO&'|'&VPNO&'|'&PUR_UNP_APL_YMD as QEXP_KEY
		AND T1.VAAT_CNSU_NO = T2.VAAT_CNSU_NO		-- [T2]	Load distinct VAAT_CORP_CD&'|'&VAAT_CNSU_NO&'|'&VPNO&'|'&PUR_UNP_APL_YMD as QEXP_KEY
		AND T1.VPNO = T2.VPNO
		AND T1.PUR_UNP_APL_YMD = T2.PUR_UNP_APL_YMD
		) QEXP_Tmp
	ON  Fact_Tmp.VAAT_CORP_CD = QEXP_Tmp.VAAT_CORP_CD		
	AND Fact_Tmp.VAAT_CNSU_NO = QEXP_Tmp.VAAT_CNSU_NO	
	AND Fact_Tmp.VPNO = QEXP_Tmp.VPNO						
	AND Fact_Tmp.PUR_UNP_APL_YMD = QEXP_Tmp.PUR_UNP_APL_YMD
	),
/*========================================================================
								Fact_G_ERP
========================================================================*/
Fact_G_ERP_Tmp AS (
	SELECT
		  T1.*
		, T3.DVLP_DCD	-- 담당부서코드
		, T3.PPRR_ID	-- 담당자사번 
		, T3.PPRR_NM	-- 담당자	
		, T3.LDC_RT		-- LDC율
		, T3.CRTN_XR	-- 기준환율
	FROM (
		SELECT 
			  '해외' AS AREA
			, 'ERP' AS AREA_GUBUN
			, VAAT_CORP_CD
			, VPNO
			, FIRM_CD                    -- 업체코드
			, UNP_NOS                    -- 차수
		--	, DMSD_XPO_SCN_CD
			, PUR_UNP_APL_YMD            -- 적용시점
			, TO_DATE(PUR_UNP_APL_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS "ProcDate"   -- 적용시점		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		--	, INP_YMD
			, CSDY_AMT                   -- 관세
			, PUR_UNP                    -- 가격
		--	, PRE_PUR_UNP
		--	, PUSR1_CD
		--	, UNP_DFF_AMT
		--	, T2USR1_CD
		--	, TH2_UNP_DFF_AMT
			, VAAT_CNSU_NO               -- 품의번호
		--	, CSDY_SCN_CD
		--	, UTM_QTY
			, PCE_APL_QTY AS PRICE_UNIT         -- PRICE_UNIT
		--	, USE_YN
			, BZTC_CURR_CD                -- 통화
		--	, BUPA_SEND_D
		--	, ETL_LOAD_DATE
		FROM GPOSADM.TABLE10	/* 해외ERP가격품의서정보 */	-- 17,795,742
		WHERE PUR_UNP_APL_YMD BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -61), 'YYYYMMDD') 	-- 최근 5년
					  AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMMDD')		-- 9,971,679
		) T1
	INNER JOIN (
		SELECT 
			  VAAT_CORP_CD
			, VPNO
			, FIRM_CD
			, UNP_NOS
		FROM GPOSADM.TABLE11	/* 해외ERP가격품의서정보 */	-- 1,088,966
		) T2
	ON  T1.VAAT_CORP_CD = T2.VAAT_CORP_CD
	AND T1.VPNO = T2.VPNO
	AND T1.FIRM_CD = T2.FIRM_CD	
	AND T1.UNP_NOS = T2.UNP_NOS
	INNER JOIN (
		SELECT
			  VAAT_CORP_CD                 -- 관리법인
			, VAAT_CNSU_NO                 -- 품의번호
			, DVLP_DCD                       -- 담당부서코드
			, PPRR_ID                        -- 담당자사번 
			, PPRR_NM                        -- 담당자
			, LDC_RT                      -- LDC율
			, CRTN_XR                     -- 기준환율
		FROM TABLE2
	) T3
	ON  T1.VAAT_CORP_CD = T3.VAAT_CORP_CD
	AND T1.VAAT_CNSU_NO = T3.VAAT_CNSU_NO
	),
Fact_G_ERP AS (
	SELECT 	  
		  Fact_Tmp.AREA
		, Fact_Tmp.AREA_GUBUN		
		, Fact_Tmp.VPNO
		, Fact_Tmp.FIRM_CD               -- 업체코드
		, Fact_Tmp.UNP_NOS               -- 차수
		, Fact_Tmp.PUR_UNP_APL_YMD       -- 적용시점
		, Fact_Tmp."ProcDate"			--적용시점
		, Fact_Tmp.CSDY_AMT				-- 관세
		, Fact_Tmp.PUR_UNP               -- 가격
		, Fact_Tmp.BZTC_CURR_CD          -- 통화
		, Fact_Tmp.PRICE_UNIT  			-- PRICE_UNIT
		, Fact_Tmp.VAAT_CNSU_NO          -- 품의번호
		, QEXP_Tmp.QEXP
		, Fact_Tmp.VAAT_CORP_CD          -- 관리법인
		, Fact_Tmp.DVLP_DCD	-- 담당부서코드
		, Fact_Tmp.PPRR_ID	-- 담당자사번 
		, Fact_Tmp.PPRR_NM	-- 담당자	
		, Fact_Tmp.LDC_RT		-- LDC율
		, Fact_Tmp.CRTN_XR	-- 기준환율
	FROM Fact_G_ERP_Tmp AS Fact_Tmp
	LEFT JOIN (
		SELECT
			  T1.VAAT_CORP_CD
			, T1.VAAT_CNSU_NO
			, T1.VPNO
			, T1.PUR_UNP_APL_YMD
			, T1.QEXP
		FROM (
			SELECT 
				  VAAT_CORP_CD
				, VAAT_CNSU_NO
				, VPNO
				, PUR_UNP_APL_YMD
				, QEXP
			FROM GPOSADM.TABLE12		/* 해외ERP가격품의서정보 */		-- 7,019,247
			WHERE PUR_UNP_APL_YMD BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -61), 'YYYYMMDD') 	-- 최근 5년
								  AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMMDD')		-- 2,986,403
			) T1
		INNER JOIN Fact_G_ERP_Tmp T2
		ON  T1.VAAT_CORP_CD = T2.VAAT_CORP_CD		-- [T1]	VAAT_CORP_CD&'|'&VAAT_CNSU_NO&'|'&VPNO&'|'&PUR_UNP_APL_YMD as QEXP_KEY
		AND T1.VAAT_CNSU_NO = T2.VAAT_CNSU_NO		-- [T2]	Load distinct VAAT_CORP_CD&'|'&VAAT_CNSU_NO&'|'&VPNO&'|'&PUR_UNP_APL_YMD as QEXP_KEY
		AND T1.VPNO = T2.VPNO							
		AND T1.PUR_UNP_APL_YMD = T2.PUR_UNP_APL_YMD		
		) QEXP_Tmp
	ON  Fact_Tmp.VAAT_CORP_CD = QEXP_Tmp.VAAT_CORP_CD		
	AND Fact_Tmp.VAAT_CNSU_NO = QEXP_Tmp.VAAT_CNSU_NO	
	AND Fact_Tmp.VPNO = QEXP_Tmp.VPNO						
	AND Fact_Tmp.PUR_UNP_APL_YMD = QEXP_Tmp.PUR_UNP_APL_YMD
	),
TABLE13 AS ( 
	SELECT 
		  VAAT_CO_CD
		, CD_G_CD
		, CD_ID
		, CD_EXPL_SBC
		, N1_MAPP_CD_NM
		, GLB_LANG_CD
	FROM GPOSADM.TABLE13		/* 상세코드마스터 */	-- 289,908
	),
TABLE15 AS (
	SELECT DISTINCT 
	  VAAT_CNSU_NO
	, '1' AS CNT 
	FROM GPOSADM.TABLE15		/* 가격품의정산조건정보 */ 	-- 7,937,950
	)
/*========================================================================
  End of With
========================================================================*/
/*----------------------------------- Fact_Final ---------------------------------*/
SELECT
	  F.AREA
	, F.AREA_GUBUN		
	, F.VPNO
	, F.FIRM_CD					-- 업체코드
	, F.UNP_NOS					-- 차수
	, F.PUR_UNP_APL_YMD			-- 적용시점
	, F."ProcDate"				--적용시점
	, F.CSDY_AMT				-- 관세
	, F.PUR_UNP					-- 가격
	, F.BZTC_CURR_CD			-- 통화
	, F.PRICE_UNIT				-- PRICE_UNIT
	, F.VAAT_CNSU_NO			-- 품의번호
	, F.QEXP
	, F.VAAT_CORP_CD			-- 관리법인
	, F.DVLP_DCD				-- 담당부서코드
	, F.PPRR_ID					-- 담당자사번 
	, F.PPRR_NM					-- 담당자	
	, F.LDC_RT					-- LDC율
	, F.CRTN_XR					-- 기준환율
	, F.VPNO_KEY
	, CASE WHEN jj_YN.CNT IS NULL THEN 'N' ELSE 'Y' END AS jj_YN
	, FIRM_CD.FIRM_NM
	, DVLP_DCD.DVLP_NM
	, VPNO_CD.PART_NM
	, VAAT_CORP_CD.VAAT_CO_CD
	, VAAT_CORP_CD.VAAT_CO_NM
FROM (
	SELECT 
		  Fact_K1.*
		, Fact_K1.VPNO AS VPNO_KEY
	FROM Fact_K1
	UNION ALL
	SELECT
		  Fact_K2.*
		, Fact_K2.VPNO AS VPNO_KEY
	FROM Fact_K2
	UNION ALL 
	SELECT 
		  Fact_G_A400.*
		, Fact_G_A400.VAAT_CORP_CD || '|' || Fact_G_A400.VPNO AS VPNO_KEY
	FROM Fact_G_A400
	UNION ALL
	SELECT 
		  Fact_G_ERP.*
		, Fact_G_ERP.VAAT_CORP_CD || '|' || Fact_G_ERP.VPNO AS VPNO_KEY
	FROM Fact_G_ERP
	) F	
/*------------------------------------- jj_YN ------------------------------------*/
LEFT JOIN ( 
	SELECT DISTINCT		-- jj_YN_K1_Tmp
		  T1.AREA
		, T1.AREA_GUBUN
		, T1.VAAT_CNSU_NO
		, T2.CNT
	FROM Fact_K1 T1 LEFT JOIN ( SELECT DISTINCT VAAT_CNSU_NO, '1' AS CNT FROM GPOSADM.TABLE14 /* 가격품의정산조건정보 */ ) T2
	ON T1.VAAT_CNSU_NO = T2.VAAT_CNSU_NO
	UNION ALL 
	SELECT DISTINCT		-- jj_YN_K2_Tmp
		  AREA
		, AREA_GUBUN
		, VAAT_CNSU_NO
		, 'N' AS CNT
	FROM Fact_K2
	UNION ALL
	SELECT DISTINCT		-- jj_YN_A400_Tmp
		  T1.AREA
		, T1.AREA_GUBUN
		, T1.VAAT_CNSU_NO
		, T2.CNT
	FROM Fact_G_A400 T1 LEFT JOIN ( SELECT VAAT_CNSU_NO, CNT FROM TABLE15 ) T2
	ON T1.VAAT_CNSU_NO = T2.VAAT_CNSU_NO
	UNION ALL
	SELECT DISTINCT		-- jj_YN_ERP_Tmp
		  T1.AREA
		, T1.AREA_GUBUN
		, T1.VAAT_CNSU_NO
		, T2.CNT
	FROM Fact_G_ERP T1 LEFT JOIN ( SELECT VAAT_CNSU_NO, CNT FROM TABLE15 ) T2
	ON T1.VAAT_CNSU_NO = T2.VAAT_CNSU_NO
	) jj_YN
ON  F.AREA 			= jj_YN.AREA				-- [F]		AREA&'|'&AREA_GUBUN&'|'&VAAT_CNSU_NO AS jj_YN_K1_KEY (jj_YN_K2_KEY, jj_YN_A400_KEY, jj_YN_ERP_KEY 동일)
AND F.AREA_GUBUN 	= jj_YN.AREA_GUBUN			-- [jj_YN]	AREA&'|'&AREA_GUBUN&'|'&VAAT_CNSU_NO AS jj_YN_KEY
AND F.VAAT_CNSU_NO 	= jj_YN.VAAT_CNSU_NO
/*----------------------------------- Dimension ----------------------------------*/
LEFT JOIN (
	SELECT 
		  T1.VEND_CD
		, T1.VEND_NM_EXT AS FIRM_NM
		, T2.VAAT_CORP_CD
	FROM GPOSADM.TABLE16 T1		/* *업체마스터 */	-- 141,826
	INNER JOIN (
		SELECT 
			  CD_EXPL_SBC AS VAAT_CO_CD
			, CD_ID AS VAAT_CORP_CD
		FROM TABLE13
		WHERE 1=1
			AND CD_G_CD = 'S0037'
			AND GLB_LANG_CD = 'KO'
		) T2
	ON T1.VAAT_CO_CD = T2.VAAT_CO_CD
	) FIRM_CD
ON  F.VAAT_CORP_CD	= FIRM_CD.VAAT_CORP_CD		-- [F]			VAAT_CORP_CD&'|'&FIRM_CD AS FIRM_CD_KEY
AND F.FIRM_CD 		= FIRM_CD.VEND_CD			-- [FIRM_CD]	Exists(FIRM_CD_KEY, VAAT_CORP_CD&'|'&VEND_CD)
LEFT JOIN (
	SELECT 
		  MAX(T1.OPS_NM) AS DVLP_NM
		, T1.DEPT_CD
		, T2.VAAT_CORP_CD
	FROM (
		SELECT 
			  CASE WHEN VAAT_CO_CD IN ('HMC','KMC') THEN 'HKMC' ELSE VAAT_CO_CD END	AS VAAT_CO_CD
			, OPS_NM
			, DEPT_CD
		FROM GPOSADM.TABLE17		/* *부서코드 */	-- 56,336
		) T1
	INNER JOIN (
			SELECT 
				  CD_EXPL_SBC AS VAAT_CO_CD
				, CD_ID AS VAAT_CORP_CD
			FROM TABLE13
			WHERE 1=1
				AND CD_G_CD = 'S0037'
				AND GLB_LANG_CD = 'KO'
			) T2
	ON T1.VAAT_CO_CD = T2.VAAT_CO_CD
	GROUP BY DEPT_CD, VAAT_CORP_CD
	) DVLP_DCD
ON  F.VAAT_CORP_CD	= DVLP_DCD.VAAT_CORP_CD		-- [F]			VAAT_CORP_CD&'|'&DVLP_DCD AS DVLP_DCD_KEY
AND F.DVLP_DCD		= DVLP_DCD.DEPT_CD			-- [DVLP_DCD]	Exists(DVLP_DCD_KEY, VAAT_CORP_CD&'|'&DEPT_CD)
LEFT JOIN (
	SELECT	-- 국내
		  OC01_PART_NO AS VPNO_KEY		-- 품번		-- Exists(VPNO_KEY, VAAT_CORP_CD&'|'&VPNO)
		, OC01_PART_DESC AS PART_NM 	-- 품명
	FROM GPOSADM.TABLE18		-- 31,131,679
	UNION ALL 
	SELECT	-- 해외
		  VAAT_CORP_CD || '|' || VPNO AS VPNO_KEY	-- Exists(VPNO_KEY, VAAT_CORP_CD&'|'&VPNO)
		, PART_NM
	FROM GPOSADM.TABLE19		-- 2,122,038
	) VPNO_CD
ON F.VPNO_KEY = VPNO_CD.VPNO_KEY
LEFT JOIN (
	SELECT 
		  CD_ID AS VAAT_CORP_CD_KEY
		, CD_EXPL_SBC AS VAAT_CO_CD
		, N1_MAPP_CD_NM AS VAAT_CO_NM
	FROM TABLE13
	WHERE 1=1
		AND CD_G_CD = 'S0759'				
		AND GLB_LANG_CD = 'KO'
	) VAAT_CORP_CD
ON F.VAAT_CORP_CD = VAAT_CORP_CD.VAAT_CORP_CD_KEY	-- [F]				VAAT_CORP_CD AS VAAT_CORP_CD_KEY
													-- [VAAT_CORP_CD]	Exists(VAAT_CORP_CD_KEY, CD_ID)

