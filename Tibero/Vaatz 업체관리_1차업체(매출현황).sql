-- Vaatz 업체관리_1차업체(매출현황)

/* 작성자 : 이소진
 * 작업내역 : 2025.05.19 최초 작성
 * 
 * DB Connection : GPOSADM_VER
 * 
 * [Target/Source 앱]
 * Vaatz_초기적재(업체관리)
 * 
 * [Table]
 * TABLE1	추가코드정보
 * TABLE2		개발능력평가_상용
 * TABLE3	업체기본정보_다국어_공통정보
 * TABLE4		협업입력 재무정보 관리
 * TABLE5		신용평가기관 재무정보 관리
 * TABLE6	재무손익
 * TABLE7	매출현황(해외진출1차)
 * TABLE8		SQ 재무/매출
 * TABLE9		업체기본정보_개별정보
 *  
 * */

/*-------------------------------- 정보정제(1차 수정) --------------------------------*/
WITH _COMM AS (
	SELECT
		  CORP_GB  -- 코드그룹
		, CODE_ID  -- 코드아이디
		, CODE  -- 코드
		, CONT  -- 코드명
	FROM GPOSADM.TABLE1	/* 추가코드정보 */
	WHERE 1=1
		AND LANG_CD = 'KO'
),
직납 AS (
	SELECT
		   STD_YEAR
		 , FIRM_CD
		 , TRANS_COM_YEAR_AMT
	FROM GPOSADM.TABLE2	/* 개발능력평가_상용 */
	WHERE 1=1 
		AND SN IN (1,2,5)
	),
우회납 AS (
	SELECT
		   STD_YEAR
		 , FIRM_CD
		 , TRANS_COM_YEAR_AMT
	FROM GPOSADM.TABLE2	/* 개발능력평가_상용 */
	WHERE 1=1 
		AND SN IN (3, 4, 6, 7)
	),
/*========================================================================
								테이블_B
========================================================================*/
B AS (
	SELECT    
	--	  CORP_GB&VEND_CD AS KEY_CORP_VEND  	-- CORP_GB&VEND_CD
	--	, CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY  	-- CORP_GB&VEND_CD&CRTN_Y
		  B1.CORP_GB  -- 법인구분
		, B1.VEND_CD  -- 업체코드 
		, B1.CRTN_Y AS CRTN_Y_B 		-- 평가년
		, B1.CUR AS CUR_B -- 화폐단위
		, NVL(B1.ASST_AMT,0) AS ASST_AMT_B -- 총자산
		, NVL(B1.BOND_AMT,0) AS BOND_AMT_B  -- 부채총액
		, NVL(B1.CPTA_AMT,0) AS CPTA_AMT_B 	-- 자기자본
		, NVL(B1.SALS_AMT,0) AS SALS_AMT_B  -- 매출액
		, NVL(B1.BIZ_AMT,0) AS BIZ_AMT_B  	-- 영업이익
		, NVL(B1.REG_AMT,0) AS REG_AMT_B  	-- 경상이익	
		, NVL(B1.REG_RT,0) AS REG_RT_B  	-- 매출경상이익율
		, NVL(B1.BOND_RT,0) AS BOND_RT_B   	-- 부채비율
		, NVL(B1.SALS_RT,0) AS SALS_RT_B  	-- 매출증가율
		, NVL(B1.BIZ_RT,0) AS BIZ_RT_B  	-- 영업이익율
		, NVL(B2.COM_AMT_1,0) AS COM_AMT_B1 	-- 직납
		, NVL(B3.COM_AMT_2,0) AS COM_AMT_B2 	-- 우회납
		, TO_DATE(B1.CSAC_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS CSAC_YMD_B  	-- 결산일		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, B1.EV_YMD
		, 'TempB' AS TEMP
	FROM (
		SELECT 
			  VAAT_CORP_CD AS CORP_GB  -- 법인구분
			, FIRM_CD AS VEND_CD  -- 업체코드
			, CRTN_Y || EV_YMD AS YYYYMM  -- 날짜 MAX시의 조인조건이고, VEND_CD여러건을 보여줘야 하는 요건으로 바뀜
			, CRTN_Y  -- 평가년
			, CUR  		-- 화폐단위
			, ASST_AMT 	-- 총자산
			, BOND_AMT  	-- 부채총액
			, CPTA_AMT  	-- 자기자본
			, SALS_AMT  	-- 매출액
			, BIZ_AMT  	-- 영업이익
			, REG_AMT  	-- 경상이익
			, REG_RT  		-- 매출경상이익율
			, BOND_RT  	-- 부채비율
			, SALS_RT  	-- 매출증가율
			, BIZ_RT  		-- 영업이익율
--			, CSAC_YMD  	-- 결산일
			, CASE WHEN REGEXP_LIKE(CSAC_YMD, '^[0-9]{8}$') 
				   THEN 
						CASE WHEN	( SUBSTR(CSAC_YMD,5,2) IN (1,3,5,7,8,10,12) AND SUBSTR(CSAC_YMD,7,2) BETWEEN '01' AND '31' )
								OR	( SUBSTR(CSAC_YMD,5,2) IN (4,6,9,11) AND SUBSTR(CSAC_YMD,7,2) BETWEEN '01' AND '30' )
								OR	( SUBSTR(CSAC_YMD,5,2) = '02' AND SUBSTR(CSAC_YMD,7,2) BETWEEN '01' AND '29' )
							 THEN CSAC_YMD
							 END
				   END AS CSAC_YMD		-- 이상값 Null로 치환
			, EV_YMD		-- 평가일
		FROM GPOSADM.TABLE4	/* 협업입력 재무정보 관리 */
		WHERE 1=1
			AND CRTN_Y BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -12*10), 'YYYY') AND TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, 12), 'YYYY')	-- CRTN_Y < $(vCY_F_YYYY)
			AND CRTN_Y NOT IN ('0000','0001','6','1111')
		) B1
	LEFT JOIN (
		SELECT
			  FIRM_CD
			, STD_YEAR
			, SUM(NVL(TRANS_COM_YEAR_AMT,0)) AS COM_AMT_1 -- 직납
		FROM 직납
		GROUP BY FIRM_CD, STD_YEAR
		) B2
	ON  B1.VEND_CD = B2.FIRM_CD		-- _KEY_FIRM_CRTN(_KEY_직납, 우회납) B1 : FIRM_CD & CRTN_Y  B2 : FIRM_CD & STD_YEAR
	AND B1.CRTN_Y = B2.STD_YEAR
	LEFT JOIN (
		SELECT
			  FIRM_CD
			, STD_YEAR
			, SUM(NVL(TRANS_COM_YEAR_AMT,0)) AS COM_AMT_2 -- 우회납
		FROM 우회납
		GROUP BY FIRM_CD, STD_YEAR
		) B3
	ON  B1.VEND_CD = B3.FIRM_CD		-- _KEY_FIRM_CRTN(_KEY_직납, 우회납) B1 : FIRM_CD & CRTN_Y  B3 : FIRM_CD & STD_YEAR
	AND B1.CRTN_Y = B3.STD_YEAR
	),
/*========================================================================
								테이블_C
========================================================================*/
C AS (
	SELECT 
		  C1.CORP_GB
		, C1.VEND_CD
		, C1.CRTN_Y AS CRTN_Y_C
		, C1.CUR AS CUR_C 
		, NVL(C1.ASST_AMT,0) AS ASST_AMT_C  --총자산
		, NVL(C1.BOND_AMT,0) AS BOND_AMT_C  --부채총액
		, NVL(C1.CPTA_AMT,0) AS CPTA_AMT_C  --자기자본
		, NVL(C1.SALS_AMT,0) AS SALS_AMT_C  --매출액
		, NVL(C1.BIZ_AMT,0) AS BIZ_AMT_C  --영업이익
		, NVL(C1.REG_AMT,0) AS REG_AMT_C  --경상이익
		, NVL(C1.REG_RT,0) AS REG_RT_C  --매출경상이익율
		, NVL(C1.BOND_RT,0) AS BOND_RT_C  --부채비율
		, NVL(C1.SALS_RT,0) AS SALS_RT_C  --매출증가율
		, NVL(C1.BIZ_RT,0) AS BIZ_RT_C  --영업이익율
		, NVL(C2.COM_AMT_1,0) AS COM_AMT_C1  --직납
		, NVL(C3.COM_AMT_2,0) AS COM_AMT_C2  --우회납
		, TO_DATE(C1.CSAC_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS CSAC_YMD_C  	-- 결산일		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, '' AS EV_YMD
		, 'TempC' AS TEMP
	FROM (
		SELECT 
			  VAAT_CORP_CD AS CORP_GB  -- 법인구분
			, FIRM_CD AS VEND_CD  -- 업체코드  
			, CRTN_Y || EV_YMD AS YYYYMM   -- 날짜 MAX시의 조인조건이고, VEND_CD여러건을 보여줘야 하는 요건으로 바뀜
			, CRTN_Y
			, '' AS CUR	
			, ASST_AMT  --총자산
			, BOND_AMT  --부채총액
			, CPTA_AMT  --자기자본
			, SALS_AMT  --매출액
			, BIZ_AMT  --영업이익
			, REG_AMT  --경상이익
			, REG_RT  --매출경상이익율
			, BOND_RT  --부채비율
			, SALS_RT  --매출증가율
			, BIZ_RT  --영업이익율
			, CSAC_YMD  --결산일
			, EV_YMD
		FROM GPOSADM.TABLE5		/* 신용평가기관 재무정보 관리 */
		WHERE 1=1
			AND CRTN_Y BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -12*10), 'YYYY') AND TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, 12), 'YYYY')	-- CRTN_Y < $(vCY_F_YYYY)
			AND CRTN_Y NOT IN ('0000','0001','6','1111')
		) C1
	LEFT JOIN (
		SELECT
			  FIRM_CD
			, STD_YEAR
			, SUM(NVL(TRANS_COM_YEAR_AMT,0)) AS COM_AMT_1 -- 직납
		FROM 직납
		GROUP BY FIRM_CD, STD_YEAR
		) C2
	ON  C1.VEND_CD = C2.FIRM_CD		-- _KEY_FIRM_CRTN(_KEY_직납, 우회납) B1 : FIRM_CD & CRTN_Y  B2 : FIRM_CD & STD_YEAR
	AND C1.CRTN_Y = C2.STD_YEAR
	LEFT JOIN (
		SELECT
			  FIRM_CD
			, STD_YEAR
			, SUM(NVL(TRANS_COM_YEAR_AMT,0)) AS COM_AMT_2 -- 우회납
		FROM 우회납
		GROUP BY FIRM_CD, STD_YEAR
		) C3
	ON  C1.VEND_CD = C3.FIRM_CD		-- _KEY_FIRM_CRTN(_KEY_직납, 우회납) B1 : FIRM_CD & CRTN_Y  B3 : FIRM_CD & STD_YEAR
	AND C1.CRTN_Y = C3.STD_YEAR
	),
/*========================================================================
								테이블_D
========================================================================*/
D AS (
	SELECT
		  CORP_GB  									-- 법인구분
		, VEND_CD  									-- 법인명
		, STD_YYMM AS CRTN_Y_D 						-- 평가년
		, MONEY_UNIT AS CUR_D 			
		, NVL(TOT_ASST,0) AS ASST_AMT_D  			-- 총자산
		, NVL(TOT_DEBT,0) AS BOND_AMT_D  			-- 부채총액
		, NVL(CAPITAL,0) AS CPTA_AMT_D  			-- 자기자본
		, NVL(SALE_AMT,0) AS SALS_AMT_D  			-- 매출액
		, NVL(BIZ_PROF,0) AS BIZ_AMT_D  			-- 영업이익
		, NVL(ORDI_PROF,0) AS REG_AMT_D  			-- 경상이익
		, 0 AS REG_RT_D  							-- 매출경상이익율
		, 0 AS BOND_RT_D  							-- 부채비율
		, NVL(SALE_ORDI_PROF_RATE,0) AS SALS_RT_D	-- 매출증가율 
		, NVL(ROUND(NULLIF(BIZ_PROF,0)/NULLIF(TOT_ASST,0)*100),0) AS BIZ_RT_D -- 영업이익율
		, 0 AS COM_AMT_1_D  						-- 직납
		, 0 AS COM_AMT_2_D  						-- 우회납 
--		, STD_DATE AS CSAC_YMD 						-- 결산일	
		, TO_DATE(
		  CASE WHEN REGEXP_LIKE(STD_DATE, '^[0-9]{8}$') 
			   THEN 
					CASE WHEN	( SUBSTR(STD_DATE,5,2) IN (1,3,5,7,8,10,12) AND SUBSTR(STD_DATE,7,2) BETWEEN '01' AND '31' )
							OR	( SUBSTR(STD_DATE,5,2) IN (4,6,9,11) AND SUBSTR(STD_DATE,7,2) BETWEEN '01' AND '30' )
							OR	( SUBSTR(STD_DATE,5,2) = '02' AND SUBSTR(STD_DATE,7,2) BETWEEN '01' AND '29' )
						 THEN STD_DATE
						 END
			   END 											-- 이상값 Null로 치환 
		  ,'YYYYMMDD') + INTERVAL '9' HOUR AS CSAC_YMD_D	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, '' AS EV_YMD
		, 'TempD' AS TEMP
	FROM GPOSADM.TABLE6	/* 재무손익 */
	WHERE 1=1
		AND STAT IN ('C','R')
		AND LENGTH(STD_DATE) >= 8
		AND STD_YYMM BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -12*10), 'YYYY') AND TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, 12), 'YYYY')	-- STD_YYMM < $(vCY_F_YYYY)
		AND STD_YYMM NOT IN ('0000','0001','6','1111') 
	),
/*========================================================================
								테이블_E
========================================================================*/
E AS (
	SELECT 
		  CORP_GB  				-- 법인구분
		, FIRM_CD AS VEND_CD	-- 업체코드
		, STD_YEAR AS CRTN_Y_E	-- 평가년
		, MONEY_UNIT AS CUR_E  
		, 0 AS ASST_AMT_E  		--총자산
		, 0 AS BOND_AMT_E  		--부채총액
		, 0 AS CPTA_AMT_E  		--자기자본
		, 0 AS SALS_AMT_E 		--매출액
		, 0 AS BIZ_AMT_E  		--영업이익
		, 0 AS REG_AMT_E 		--경상이익
		, 0 AS REG_RT_E  		--매출경상이익율
		, 0 AS BOND_RT_E  		--부채비율
		, 0 AS SALS_RT_E  		--매출증가율
		, NVL(ROUND(NULLIF(BIZ_PROFIT,0)/NULLIF(TOT_SALE_AMT,0)*100),0) AS BIZ_RT_E -- 영업이익율
		, 0 AS COM_AMT_1_E  	-- 직납
		, 0 AS COM_AMT_2_E  	-- 우회납 
		, TO_DATE(INP_YMD,'YYYYMMDD') + INTERVAL '9' HOUR AS CSAC_YMD_E 			-- 결산일 	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, '' AS EV_YMD
		, 'TempE' AS TEMP
	FROM GPOSADM.TABLE7	/* 매출현황(해외진출1차) */
	WHERE 1=1
		AND VAAT_ST_CD IN ('C','R')
		AND STD_YEAR BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -12*10), 'YYYY') AND TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, 12), 'YYYY')	-- STD_YEAR < $(vCY_F_YYYY)
		AND STD_YEAR NOT IN ('0000','0001','6','1111')
	),
/*========================================================================
								테이블_F
========================================================================*/
F AS (
	SELECT 
		  '' AS CORP_GB 					-- 법인구분
		, VEND_CD  							-- 업체코드
		, STD_YEAR AS CRTN_Y_F				-- 평가년
		, MONEY_UNIT AS CUR_F  
		, NVL(TOT_ASST,0) AS ASST_AMT_F		--총자산
		, NVL(TOT_DEBT,0) AS BOND_AMT_F		--부채총액
		, NVL(CAPITAL,0) AS CPTA_AMT_F		--자기자본
		, NVL(SALE_AMT,0) AS SALS_AMT_F		--매출액
		, NVL(ORDI_PROF,0) AS BIZ_AMT_F		--영업이익
		, 0 AS REG_AMT_F  					--경상이익
		, 0 AS REG_RT_F  					--매출경상이익율
		, NVL(DEBT_RATE,0) AS BOND_RT_F		--부채비율
		, 0 AS SALS_RT_F  					--매출증가율
		, NVL(ORDI_PROF_RATE,0) AS BIZ_RT_F	--영업이익율
		, 0 AS COM_AMT_1_F					-- 직납
		, 0 AS COM_AMT_2_F					-- 우회납 
		, TO_DATE((CASE WHEN STD_YEAR IS NULL THEN '' ELSE STD_YEAR || '0101' END),'YYYYMMDD') + INTERVAL '9' HOUR AS CSAC_YMD_F -- 결산일 	-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
		, '' AS EV_YMD
		, 'TempF' AS TEMP
	FROM GPOSADM.TABLE8		/* SQ 재무/매출 */
	WHERE 1=1
		AND STAT IN ('C','R')
		AND LENGTH(STD_YEAR) >= 4
		AND STD_YEAR BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -12*10), 'YYYY') AND TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, 12), 'YYYY')	-- STD_YEAR >= 1968 AND STD_YEAR < $(vCY_F_YYYY)
		AND STD_YEAR NOT IN ('0000','0001','6','1111')
	)
/*========================================================================
  End of With
========================================================================*/
SELECT 
	  CORP_GB    -- 법인구분
	, CORP_NAME  -- 법인명 A.CORP_GB :CORP_NAME
	, VEND_CD    -- 업체코드
	, VEND_NM_EXT -- 업체명 A.VEND_CD : VEND_NM_EXT 업체코드(승인요청번호)     
	, CODE_ID  -- 코드아이디
--	, CRTN_Y  -- 평가년  
	, VEND_TYPE  -- 업체구분
	, VEND_TYPE_NAME  --업체구분명  A.VEND_TYPE : VEND_TYPE_NAME
	, FIRM_TPIS_CD -- 업체업종    
	, CORP_GB || VEND_CD || (
		CASE WHEN CORP_GB = 'K1'
		THEN
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(CRTN_Y_B,CRTN_Y_D)
			ELSE NVL(CRTN_Y_C,CRTN_Y_D)
			END
		ELSE
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN CRTN_Y_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN CRTN_Y_F ELSE CRTN_Y_D END )
			END
		END) AS KEY_CORP_VEND_YYYY
	------------------------------------------------- CRTN_Y
	, CRTN_Y_B, CRTN_Y_C, CRTN_Y_D, CRTN_Y_E, CRTN_Y_F
	, CASE WHEN CORP_GB = 'K1'
		THEN
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(CRTN_Y_B,CRTN_Y_D)
			ELSE NVL(CRTN_Y_C,CRTN_Y_D)
			END
		ELSE
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN CRTN_Y_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN CRTN_Y_F ELSE CRTN_Y_D END )
			END
		END AS CRTN_Y          
	------------------------------------------------- CUR  // 화폐단위
	, CUR_B, CUR_C, CUR_D, CUR_E, CUR_F
	, CASE WHEN CORP_GB ='K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(CUR_B,CUR_D)       
			ELSE NVL(CUR_C,CUR_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN CUR_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN CUR_F ELSE CUR_D END )
			END
		END AS CUR
	------------------------------------------------- ASST_AMT  // 총자산
	, ASST_AMT_B, ASST_AMT_C, ASST_AMT_D, ASST_AMT_E, ASST_AMT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(ASST_AMT_B,ASST_AMT_D)       
			ELSE NVL(ASST_AMT_C,ASST_AMT_D)
			END 
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN ASST_AMT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN ASST_AMT_F ELSE ASST_AMT_D END )
			END
		END AS ASST_AMT
	------------------------------------------------- BOND_AMT  // 부채총액
	, BOND_AMT_B, BOND_AMT_C, BOND_AMT_D, BOND_AMT_E, BOND_AMT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(BOND_AMT_B,BOND_AMT_D)       
			ELSE NVL(BOND_AMT_C,BOND_AMT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN BOND_AMT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN BOND_AMT_F ELSE BOND_AMT_D END )
			END
		END AS BOND_AMT
	------------------------------------------------- CPTA_AMT  // 자기자본
	, CPTA_AMT_B, CPTA_AMT_C, CPTA_AMT_D, CPTA_AMT_E, CPTA_AMT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(CPTA_AMT_B,CPTA_AMT_D)       
			ELSE NVL(CPTA_AMT_C,CPTA_AMT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN CPTA_AMT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN CPTA_AMT_F ELSE CPTA_AMT_D END )
			END
		END AS CPTA_AMT        
	------------------------------------------------- SALS_AMT  // 매출액
	, SALS_AMT_B, SALS_AMT_C, SALS_AMT_D, SALS_AMT_E, SALS_AMT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(SALS_AMT_B,SALS_AMT_D)       
			ELSE NVL(SALS_AMT_C,SALS_AMT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN SALS_AMT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD= 'O2 ' THEN SALS_AMT_F ELSE SALS_AMT_D END )
			END
		END AS SALS_AMT
	------------------------------------------------- BIZ_AMT   // 영업이익
	, BIZ_AMT_B, BIZ_AMT_C, BIZ_AMT_D, BIZ_AMT_E, BIZ_AMT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(BIZ_AMT_B,BIZ_AMT_D)       
			ELSE NVL(BIZ_AMT_C,BIZ_AMT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN BIZ_AMT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN BIZ_AMT_F ELSE BIZ_AMT_D END )
			END
		END AS BIZ_AMT
	------------------------------------------------- REG_AMT   // 경상이익
	, REG_AMT_B, REG_AMT_C, REG_AMT_D, REG_AMT_E, REG_AMT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(REG_AMT_B,REG_AMT_D)       
			ELSE NVL(REG_AMT_C,REG_AMT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN REG_AMT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN REG_AMT_F ELSE REG_AMT_D END )
			END
		END AS REG_AMT
	------------------------------------------------- COM_AMT_1  // C_직납
	, COM_AMT_B1, COM_AMT_C1, COM_AMT_D1, COM_AMT_E1, COM_AMT_F1
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(COM_AMT_B1,COM_AMT_D1)       
			ELSE NVL(COM_AMT_C1,COM_AMT_D1)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN COM_AMT_E1
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN COM_AMT_F1 ELSE COM_AMT_D1 END )
			END
		END AS COM_AMT_1
	------------------------------------------------- COM_AMT_2  // D_우회납
	, COM_AMT_B2, COM_AMT_C2, COM_AMT_D2, COM_AMT_E2, COM_AMT_F2
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(COM_AMT_B2,COM_AMT_D2)       
			ELSE NVL(COM_AMT_C2,COM_AMT_D2)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN COM_AMT_E2
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN COM_AMT_F2 ELSE COM_AMT_D2 END )
			END
		END AS COM_AMT_2
	------------------------------------------------- REG_RT  	// 매출경상이익율
	, REG_RT_B, REG_RT_C, REG_RT_D, REG_RT_E, REG_RT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(REG_RT_B,REG_RT_D)       
			ELSE NVL(REG_RT_C,REG_RT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN REG_RT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN REG_RT_F ELSE REG_RT_D END )
			END
		END AS REG_RT
	------------------------------------------------- BOND_RT  // 부채비율
	, BOND_RT_B, BOND_RT_C, BOND_RT_D, BOND_RT_E, BOND_RT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(BOND_RT_B,BOND_RT_D)       
			ELSE NVL(BOND_RT_C,BOND_RT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN BOND_RT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN BOND_RT_F ELSE BOND_RT_D END )
			END
		END AS BOND_RT
	------------------------------------------------- SALS_RT  // 매출증가율
	, SALS_RT_B, SALS_RT_C, SALS_RT_D, SALS_RT_E, SALS_RT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(SALS_RT_B,SALS_RT_D)       
			ELSE NVL(SALS_RT_C,SALS_RT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN BOND_RT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN SALS_RT_F ELSE SALS_RT_D END )
			END
		END AS SALS_RT
	------------------------------------------------- BIZ_RT  	// 영업이익율
	, BIZ_RT_B, BIZ_RT_C, BIZ_RT_D, BIZ_RT_E, BIZ_RT_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(BIZ_RT_B,BIZ_RT_D)       
			ELSE NVL(BIZ_RT_C,BIZ_RT_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN BIZ_RT_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN BIZ_RT_F ELSE BIZ_RT_D END )
			END
		END AS BIZ_RT
	------------------------------------------------- CSAC_YMD  // 결산일
	, CSAC_YMD_B, CSAC_YMD_C, CSAC_YMD_D, CSAC_YMD_E, CSAC_YMD_F
	, CASE WHEN CORP_GB = 'K1'
		THEN 
			CASE WHEN VEND_TYPE = 'P'
			THEN NVL(CSAC_YMD_B,CSAC_YMD_D)       
			ELSE NVL(CSAC_YMD_C,CSAC_YMD_D)
			END
		ELSE 
			CASE WHEN FIRM_TPIS_CD = 'L1'
			THEN CSAC_YMD_E
			ELSE ( CASE WHEN FIRM_TPIS_CD = 'O2' THEN CSAC_YMD_F ELSE CSAC_YMD_D END )
			END
		END AS CSAC_YMD
/*------------------------------- 정보통합(AB_CDEF) --------------------------------*/
FROM (
	SELECT
		  TA_REGCVDIS.CORP_GB  -- 법인구분
		, TA_REGCVDIS.VEND_CD  -- 업체코드
		, TA_REGCVDIS.CORP_NAME  -- 법인명 A.CORP_GB :CORP_NAME
		, TA_REGCVDIS.VEND_NM_EXT -- 업체명 A.VEND_CD : VEND_NM_EXT 업체코드(승인요청번호)     
		, TA_REGCVDIS.CODE_ID  -- 코드아이디
		, TA_REGCVDIS.VEND_TYPE  -- 업체구분
		, TA_REGCVDIS.VEND_TYPE_NAME  --업체구분명  A.VEND_TYPE : VEND_TYPE_NAME
		, TA_REGCVDIS.FIRM_TPIS_CD -- 업체업종     
		, CRTN_Y_B AS CRTN_Y		-- 평가년
		, ( CASE TEMP WHEN 'TempB' THEN CRTN_Y_B ELSE NULL END ) AS CRTN_Y_B
		, ( CASE TEMP WHEN 'TempC' THEN CRTN_Y_B ELSE NULL END ) AS CRTN_Y_C
		, ( CASE TEMP WHEN 'TempD' THEN CRTN_Y_B ELSE NULL END ) AS CRTN_Y_D
		, ( CASE TEMP WHEN 'TempE' THEN CRTN_Y_B ELSE NULL END ) AS CRTN_Y_E
		, ( CASE TEMP WHEN 'TempF' THEN CRTN_Y_B ELSE NULL END ) AS CRTN_Y_F
		, CUR_B AS CUR  -- 화폐단위
		, ( CASE TEMP WHEN 'TempB' THEN CUR_B ELSE NULL END ) AS CUR_B
		, ( CASE TEMP WHEN 'TempC' THEN CUR_B ELSE NULL END ) AS CUR_C
		, ( CASE TEMP WHEN 'TempD' THEN CUR_B ELSE NULL END ) AS CUR_D
		, ( CASE TEMP WHEN 'TempE' THEN CUR_B ELSE NULL END ) AS CUR_E
		, ( CASE TEMP WHEN 'TempF' THEN CUR_B ELSE NULL END ) AS CUR_F
		, ASST_AMT_B AS ASST_AMT -- 총자산
		, ( CASE TEMP WHEN 'TempB' THEN ASST_AMT_B ELSE NULL END ) AS ASST_AMT_B
		, ( CASE TEMP WHEN 'TempC' THEN ASST_AMT_B ELSE NULL END ) AS ASST_AMT_C
		, ( CASE TEMP WHEN 'TempD' THEN ASST_AMT_B ELSE NULL END ) AS ASST_AMT_D
		, ( CASE TEMP WHEN 'TempE' THEN ASST_AMT_B ELSE NULL END ) AS ASST_AMT_E
		, ( CASE TEMP WHEN 'TempF' THEN ASST_AMT_B ELSE NULL END ) AS ASST_AMT_F
		, BOND_AMT_B AS BOND_AMT  -- 부채총액
		, ( CASE TEMP WHEN 'TempB' THEN BOND_AMT_B ELSE NULL END ) AS BOND_AMT_B
		, ( CASE TEMP WHEN 'TempC' THEN BOND_AMT_B ELSE NULL END ) AS BOND_AMT_C
		, ( CASE TEMP WHEN 'TempD' THEN BOND_AMT_B ELSE NULL END ) AS BOND_AMT_D
		, ( CASE TEMP WHEN 'TempE' THEN BOND_AMT_B ELSE NULL END ) AS BOND_AMT_E
		, ( CASE TEMP WHEN 'TempF' THEN BOND_AMT_B ELSE NULL END ) AS BOND_AMT_F
		, CPTA_AMT_B AS CPTA_AMT 	-- 자기자본
		, ( CASE TEMP WHEN 'TempB' THEN CPTA_AMT_B ELSE NULL END ) AS CPTA_AMT_B
		, ( CASE TEMP WHEN 'TempC' THEN CPTA_AMT_B ELSE NULL END ) AS CPTA_AMT_C
		, ( CASE TEMP WHEN 'TempD' THEN CPTA_AMT_B ELSE NULL END ) AS CPTA_AMT_D
		, ( CASE TEMP WHEN 'TempE' THEN CPTA_AMT_B ELSE NULL END ) AS CPTA_AMT_E
		, ( CASE TEMP WHEN 'TempF' THEN CPTA_AMT_B ELSE NULL END ) AS CPTA_AMT_F
		, SALS_AMT_B AS SALS_AMT  -- 매출액
		, ( CASE TEMP WHEN 'TempB' THEN SALS_AMT_B ELSE NULL END ) AS SALS_AMT_B
		, ( CASE TEMP WHEN 'TempC' THEN SALS_AMT_B ELSE NULL END ) AS SALS_AMT_C
		, ( CASE TEMP WHEN 'TempD' THEN SALS_AMT_B ELSE NULL END ) AS SALS_AMT_D
		, ( CASE TEMP WHEN 'TempE' THEN SALS_AMT_B ELSE NULL END ) AS SALS_AMT_E
		, ( CASE TEMP WHEN 'TempF' THEN SALS_AMT_B ELSE NULL END ) AS SALS_AMT_F
		, BIZ_AMT_B AS BIZ_AMT  	-- 영업이익
		, ( CASE TEMP WHEN 'TempB' THEN BIZ_AMT_B ELSE NULL END ) AS BIZ_AMT_B
		, ( CASE TEMP WHEN 'TempC' THEN BIZ_AMT_B ELSE NULL END ) AS BIZ_AMT_C
		, ( CASE TEMP WHEN 'TempD' THEN BIZ_AMT_B ELSE NULL END ) AS BIZ_AMT_D
		, ( CASE TEMP WHEN 'TempE' THEN BIZ_AMT_B ELSE NULL END ) AS BIZ_AMT_E
		, ( CASE TEMP WHEN 'TempF' THEN BIZ_AMT_B ELSE NULL END ) AS BIZ_AMT_F
		, REG_AMT_B AS REG_AMT  	-- 경상이익	
		, ( CASE TEMP WHEN 'TempB' THEN REG_AMT_B ELSE NULL END ) AS REG_AMT_B
		, ( CASE TEMP WHEN 'TempC' THEN REG_AMT_B ELSE NULL END ) AS REG_AMT_C
		, ( CASE TEMP WHEN 'TempD' THEN REG_AMT_B ELSE NULL END ) AS REG_AMT_D
		, ( CASE TEMP WHEN 'TempE' THEN REG_AMT_B ELSE NULL END ) AS REG_AMT_E
		, ( CASE TEMP WHEN 'TempF' THEN REG_AMT_B ELSE NULL END ) AS REG_AMT_F
		, REG_RT_B AS REG_RT  	-- 매출경상이익율
		, ( CASE TEMP WHEN 'TempB' THEN REG_RT_B ELSE NULL END ) AS REG_RT_B
		, ( CASE TEMP WHEN 'TempC' THEN REG_RT_B ELSE NULL END ) AS REG_RT_C
		, ( CASE TEMP WHEN 'TempD' THEN REG_RT_B ELSE NULL END ) AS REG_RT_D
		, ( CASE TEMP WHEN 'TempE' THEN REG_RT_B ELSE NULL END ) AS REG_RT_E
		, ( CASE TEMP WHEN 'TempF' THEN REG_RT_B ELSE NULL END ) AS REG_RT_F
		, BOND_RT_B AS BOND_RT   	-- 부채비율
		, ( CASE TEMP WHEN 'TempB' THEN BOND_RT_B ELSE NULL END ) AS BOND_RT_B
		, ( CASE TEMP WHEN 'TempC' THEN BOND_RT_B ELSE NULL END ) AS BOND_RT_C
		, ( CASE TEMP WHEN 'TempD' THEN BOND_RT_B ELSE NULL END ) AS BOND_RT_D
		, ( CASE TEMP WHEN 'TempE' THEN BOND_RT_B ELSE NULL END ) AS BOND_RT_E
		, ( CASE TEMP WHEN 'TempF' THEN BOND_RT_B ELSE NULL END ) AS BOND_RT_F
		, SALS_RT_B AS SALS_RT  	-- 매출증가율
		, ( CASE TEMP WHEN 'TempB' THEN SALS_RT_B ELSE NULL END ) AS SALS_RT_B
		, ( CASE TEMP WHEN 'TempC' THEN SALS_RT_B ELSE NULL END ) AS SALS_RT_C
		, ( CASE TEMP WHEN 'TempD' THEN SALS_RT_B ELSE NULL END ) AS SALS_RT_D
		, ( CASE TEMP WHEN 'TempE' THEN SALS_RT_B ELSE NULL END ) AS SALS_RT_E
		, ( CASE TEMP WHEN 'TempF' THEN SALS_RT_B ELSE NULL END ) AS SALS_RT_F
		, BIZ_RT_B AS BIZ_RT  	-- 영업이익율
		, ( CASE TEMP WHEN 'TempB' THEN BIZ_RT_B ELSE NULL END ) AS BIZ_RT_B
		, ( CASE TEMP WHEN 'TempC' THEN BIZ_RT_B ELSE NULL END ) AS BIZ_RT_C
		, ( CASE TEMP WHEN 'TempD' THEN BIZ_RT_B ELSE NULL END ) AS BIZ_RT_D
		, ( CASE TEMP WHEN 'TempE' THEN BIZ_RT_B ELSE NULL END ) AS BIZ_RT_E
		, ( CASE TEMP WHEN 'TempF' THEN BIZ_RT_B ELSE NULL END ) AS BIZ_RT_F
		, COM_AMT_B1 AS COM_AMT_1 	-- 직납
		, ( CASE TEMP WHEN 'TempB' THEN COM_AMT_B1 ELSE NULL END ) AS COM_AMT_B1
		, ( CASE TEMP WHEN 'TempC' THEN COM_AMT_B1 ELSE NULL END ) AS COM_AMT_C1
		, ( CASE TEMP WHEN 'TempD' THEN COM_AMT_B1 ELSE NULL END ) AS COM_AMT_D1
		, ( CASE TEMP WHEN 'TempE' THEN COM_AMT_B1 ELSE NULL END ) AS COM_AMT_E1
		, ( CASE TEMP WHEN 'TempF' THEN COM_AMT_B1 ELSE NULL END ) AS COM_AMT_F1
		, COM_AMT_B2 AS COM_AMT_2 	-- 우회납
		, ( CASE TEMP WHEN 'TempB' THEN COM_AMT_B2 ELSE NULL END ) AS COM_AMT_B2
		, ( CASE TEMP WHEN 'TempC' THEN COM_AMT_B2 ELSE NULL END ) AS COM_AMT_C2
		, ( CASE TEMP WHEN 'TempD' THEN COM_AMT_B2 ELSE NULL END ) AS COM_AMT_D2
		, ( CASE TEMP WHEN 'TempE' THEN COM_AMT_B2 ELSE NULL END ) AS COM_AMT_E2
		, ( CASE TEMP WHEN 'TempF' THEN COM_AMT_B2 ELSE NULL END ) AS COM_AMT_F2
		, CSAC_YMD_B AS CSAC_YMD  	-- 결산일
		, ( CASE TEMP WHEN 'TempB' THEN CSAC_YMD_B ELSE NULL END ) AS CSAC_YMD_B
		, ( CASE TEMP WHEN 'TempC' THEN CSAC_YMD_B ELSE NULL END ) AS CSAC_YMD_C
		, ( CASE TEMP WHEN 'TempD' THEN CSAC_YMD_B ELSE NULL END ) AS CSAC_YMD_D
		, ( CASE TEMP WHEN 'TempE' THEN CSAC_YMD_B ELSE NULL END ) AS CSAC_YMD_E
		, ( CASE TEMP WHEN 'TempF' THEN CSAC_YMD_B ELSE NULL END ) AS CSAC_YMD_F
		, EV_YMD
		, TEMP
	FROM (
		/*========================================================================
		  B
		========================================================================*/
		SELECT * FROM B
		UNION ALL (
		/*========================================================================
		  C -> B UNION C not Exists 반영
		========================================================================*/
			SELECT C.* FROM B FULL OUTER JOIN C
			ON  B.CORP_GB  = C.CORP_GB
			AND B.VEND_CD  = C.VEND_CD
			AND B.CRTN_Y_B = C.CRTN_Y_C 
			WHERE   B.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
				AND B.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
				AND B.CRTN_Y_B IS NULL
			)						
		UNION ALL (
		/*========================================================================
		  D -> B UNION C not Exists 결과(BC)에 UNION D not Exists 반영
		========================================================================*/
			SELECT D.* 
			FROM (
				SELECT * FROM B
				UNION ALL (
					SELECT C.* FROM B FULL OUTER JOIN C
					ON  B.CORP_GB  = C.CORP_GB
					AND B.VEND_CD  = C.VEND_CD
					AND B.CRTN_Y_B = C.CRTN_Y_C 
					WHERE   B.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
						AND B.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
						AND B.CRTN_Y_B IS NULL
					)
				) BC FULL OUTER JOIN D		/* UNION D not Exists */ 
			ON  BC.CORP_GB  = D.CORP_GB
			AND BC.VEND_CD  = D.VEND_CD
			AND BC.CRTN_Y_B = D.CRTN_Y_D
			WHERE   BC.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
				AND BC.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
				AND BC.CRTN_Y_B IS NULL
			)
		UNION ALL (
		/*========================================================================
		  E -> BC UNION D not Exists 결과(BCD)에 UNION E not Exists 반영
		========================================================================*/
			SELECT E.*
			FROM (
				SELECT * FROM B
				UNION ALL (
					SELECT C.* FROM B FULL OUTER JOIN C
					ON  B.CORP_GB  = C.CORP_GB
					AND B.VEND_CD  = C.VEND_CD
					AND B.CRTN_Y_B = C.CRTN_Y_C 
					WHERE   B.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
						AND B.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
						AND B.CRTN_Y_B IS NULL
					)
				UNION ALL (
					SELECT D.* 
					FROM (
						SELECT * FROM B
						UNION ALL (
							SELECT C.* FROM B FULL OUTER JOIN C
							ON  B.CORP_GB  = C.CORP_GB
							AND B.VEND_CD  = C.VEND_CD
							AND B.CRTN_Y_B = C.CRTN_Y_C 
							WHERE   B.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
								AND B.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
								AND B.CRTN_Y_B IS NULL
							)
						) BC FULL OUTER JOIN D
					ON  BC.CORP_GB  = D.CORP_GB
					AND BC.VEND_CD  = D.VEND_CD
					AND BC.CRTN_Y_B = D.CRTN_Y_D
					WHERE   BC.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
						AND BC.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
						AND BC.CRTN_Y_B IS NULL
					)
				) BCD FULL OUTER JOIN E			/* UNION E not Exists */ 
			ON  BCD.CORP_GB  = E.CORP_GB
			AND BCD.VEND_CD  = E.VEND_CD
			AND BCD.CRTN_Y_B = E.CRTN_Y_E
			WHERE   BCD.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
				AND BCD.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
				AND BCD.CRTN_Y_B IS NULL
			)
		UNION ALL (
		/*========================================================================
		  F -> BCD UNION E not Exists 결과(BCDE)에 UNION F not Exists 반영
		========================================================================*/
			SELECT F.*
			FROM (
				SELECT * FROM B
				UNION ALL (
					SELECT C.* FROM B FULL OUTER JOIN C
					ON  B.CORP_GB  = C.CORP_GB
					AND B.VEND_CD  = C.VEND_CD
					AND B.CRTN_Y_B = C.CRTN_Y_C 
					WHERE   B.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
						AND B.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
						AND B.CRTN_Y_B IS NULL
					)			
				UNION ALL (
					SELECT D.* 
					FROM (
						SELECT * FROM B
						UNION ALL (
							SELECT C.* FROM B FULL OUTER JOIN C
							ON  B.CORP_GB  = C.CORP_GB
							AND B.VEND_CD  = C.VEND_CD
							AND B.CRTN_Y_B = C.CRTN_Y_C 
							WHERE   B.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
								AND B.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
								AND B.CRTN_Y_B IS NULL
							)
						) BC FULL OUTER JOIN D
					ON  BC.CORP_GB  = D.CORP_GB
					AND BC.VEND_CD  = D.VEND_CD
					AND BC.CRTN_Y_B = D.CRTN_Y_D
					WHERE   BC.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
						AND BC.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
						AND BC.CRTN_Y_B IS NULL
					)
				UNION ALL (
					SELECT E.*
					FROM (
						SELECT * FROM B
						UNION ALL (
							SELECT C.* FROM B FULL OUTER JOIN C
							ON  B.CORP_GB  = C.CORP_GB
							AND B.VEND_CD  = C.VEND_CD
							AND B.CRTN_Y_B = C.CRTN_Y_C 
							WHERE   B.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
								AND B.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
								AND B.CRTN_Y_B IS NULL
							)
						UNION ALL (
							SELECT D.* 
							FROM (
								SELECT * FROM B
								UNION ALL (
									SELECT C.* FROM B FULL OUTER JOIN C
									ON  B.CORP_GB  = C.CORP_GB
									AND B.VEND_CD  = C.VEND_CD
									AND B.CRTN_Y_B = C.CRTN_Y_C 
									WHERE   B.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
										AND B.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
										AND B.CRTN_Y_B IS NULL
									)
								) BC FULL OUTER JOIN D
							ON  BC.CORP_GB  = D.CORP_GB
							AND BC.VEND_CD  = D.VEND_CD
							AND BC.CRTN_Y_B = D.CRTN_Y_D
							WHERE   BC.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
								AND BC.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
								AND BC.CRTN_Y_B IS NULL
							)
						) BCD FULL OUTER JOIN E			/* UNION E not Exists */
					ON  BCD.CORP_GB  = E.CORP_GB
					AND BCD.VEND_CD  = E.VEND_CD
					AND BCD.CRTN_Y_B = E.CRTN_Y_E
					WHERE   BCD.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
						AND BCD.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
						AND BCD.CRTN_Y_B IS NULL
					)
				) BCDE FULL OUTER JOIN F
			ON  BCDE.CORP_GB  = F.CORP_GB
			AND BCDE.VEND_CD  = F.VEND_CD
			AND BCDE.CRTN_Y_B = F.CRTN_Y_F
			WHERE   BCDE.CORP_GB IS NULL 		-- WHERE not Exists(KEY_HASH,AutonumberHash128(KEY_CORP_VEND_YYYY))
				AND BCDE.VEND_CD IS NULL 		-- CORP_GB&VEND_CD&CRTN_Y AS KEY_CORP_VEND_YYYY
				AND BCDE.CRTN_Y_B IS NULL
			)
		) TEMP_ASSET_INFO
	/*----------------------------------- 테이블_A ------------------------------------*/
	LEFT JOIN (
		SELECT 
		--	  A1.KEY_CORP_VEND  	-- CORP_GB&VEND_CD <-- KEY_B, KEY_C, KEY_D, KEY_E, KEY_F   
			  A1.CORP_GB  	-- 법인구분
			, A1.CORP_NAME 	-- A.CORP_GB :CORP_NAME
			, A1.VEND_CD  	-- 업체코드
			, A1.VEND_NM_EXT 	-- A.VEND_CD : VEND_NM_EXT 업체코드(승인요청번호)
			, A1.VEND_TYPE  	-- 업체구분
			, A1.VEND_TYPE_NAME  	-- A.VEND_TYPE : VEND_TYPE_NAME
			, A1.FIRM_TPIS_CD 	-- 업체업종   
			, A2.CODE_ID	
		FROM (
			SELECT 
				  T.CORP_GB  -- 법인구분
				, CASE WHEN M_법인명.CORP_NAME IS NULL THEN T.CORP_GB ELSE M_법인명.CORP_NAME END AS CORP_NAME -- A.CORP_GB : CORP_NAME
				, T.VEND_CD  -- 업체코드
				, CASE WHEN M_업체정보.VEND_NM_EXT IS NULL THEN T.VEND_CD ELSE M_업체정보.VEND_NM_EXT END AS VEND_NM_EXT -- A.VEND_CD : VEND_NM_EXT 업체코드(승인요청번호)     
				, T.VEND_TYPE  -- 업체구분
				, CASE WHEN M_업체구분명.VEND_TYPE_NAME IS NULL THEN T.VEND_TYPE ELSE M_업체구분명.VEND_TYPE_NAME END AS VEND_TYPE_NAME  -- A.VEND_TYPE : VEND_TYPE_NAME
				, T.FIRM_TPIS_CD -- 업체업종   
		--		, T.CORP_GB&T.VEND_CD AS KEY_CORP_VEND  -- KEY_B, KEY_C, KEY_D, KEY_E, KEY_F
			FROM (
				SELECT
					  CORP_GB  -- 법인구분
					, VEND_CD  -- 업체코드  
					, VEND_TYPE  -- 업체구분
					, FIRM_TPIS_CD -- 업체업종   
				FROM GPOSADM.TABLE9		/* 업체기본정보_개별정보 */
				WHERE 1=1
					AND CORP_GB IN ('K1','C1','C2','A1','A2','A7','A9','S1','S2','I1','I2','T1')
				) T
			LEFT JOIN (
				SELECT
					  CODE -- AS KEY_법인  // A.CORP_GB :CORP_NAME
					, CONT AS CORP_NAME
				FROM _COMM
				WHERE 1=1
					AND CODE_ID = 'CORP_CD'
				) M_법인명
			ON T.CORP_GB = M_법인명.CODE		-- ApplyMap('M_법인명', CORP_GB) AS CORP_NAME
			LEFT JOIN (
				SELECT
					  CODE -- AS KEY_업체구분  // A.VEND_TYPE : VEND_TYPE_NAME
					, CONT AS VEND_TYPE_NAME
				FROM _COMM
				WHERE 1=1
					AND CODE_ID = 'VEND_TYPE'
				) M_업체구분명
			ON T.VEND_TYPE = M_업체구분명.CODE	-- ApplyMap('M_업체구분명', VEND_TYPE) AS VEND_TYPE_NAME
			LEFT JOIN (
				SELECT
					  VEND_CD -- AS KEY_업체 // A.VEND_CD : VEND_NM_EXT 업체코드(승인요청번호)     
					, VEND_NM_EXT  -- 업체명    
				FROM GPOSADM.TABLE3		/* 업체기본정보_다국어_공통정보 */
				WHERE 1=1
					AND LANG_CD = 'KO'
				) M_업체정보
			ON T.VEND_CD = M_업체정보.VEND_CD		-- ApplyMap('M_업체정보', VEND_CD) AS VEND_NM_EXT
			) A1
		LEFT JOIN (
			SELECT 
				  CODE AS VEND_CD 
				, CODE_ID
			FROM _COMM
			WHERE 1=1
				AND CODE_ID IN ('V033_LIST','VEND_TYPE','CORP_CD')
			) A2
		ON A1.VEND_CD = A2.VEND_CD
		) TA_REGCVDIS
	ON  TEMP_ASSET_INFO.CORP_GB = TA_REGCVDIS.CORP_GB
	AND TEMP_ASSET_INFO.VEND_CD = TA_REGCVDIS.VEND_CD
) Fact
