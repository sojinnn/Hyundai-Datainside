-- Vaatz 업체관리_1차업체(일반정보) 

/* 작성자 : 이소진
 * 작업내역 : 2025.05.13 최초 작성
 * 
 * DB Connection : GPOSADM_VER
 * 
 * [Target/Source 앱]
 * Vaatz_초기적재(업체관리)
 * 
 * [Fact Table]
 * TABLE1	업체기본정보_개별정보
 * TABLE2	업체기본정보
 * TABLE3	업체기본정보_다국어_공통정보
 * 
 * [Master Table]
 * TABLE4	추가코드정보
 * TABLE5	부서코드(다국어) 
 * TABLE6	기본코드정보
 * TABLE7	주요생산품목관리
 * TABLE8	주요생산품목관리_다국어
 * 
 * */

/*---------------------------------- 업체 기본정보 ----------------------------------*/
WITH T_COMP_BASIC AS (
	SELECT	
		  CORP_GB AS CORP_GB_A	-- 법인구분 -- 등록법인을 가져오기위한 컬럼 24.02.22
		, VEND_CD  -- 업체코드
	  	, VEND_TYPE  -- 업체구분
		, VEND_FORM_GB  -- 업체유형
		, REGST_DEPT_CD AS REGST_DEPT_CD_A -- 관리부서
		, PURCH_STOP_YN  -- 일시정지여부
		, MODI_DATE  -- 사용구분변경일  
		, SUMUP_REGN -- 대금계상지
		, BIZ_CLASS_CD -- 업종코드
		, VEND_FORM -- 업체형태
		, FIRM_TPIS_CD -- 업체업종
	FROM GPOSADM.TABLE1  /* 업체기본정보_개별정보 */
	WHERE 1=1
		-- 업체코드는 영문으로 시작하는 4자리코드만 정상  
		-- 업체코드 첫째자리가 숫자나 특수문자는 미포함 
		AND LENGTH(VEND_CD) = 4
		AND SUBSTRING(VEND_CD,1,1) NOT IN ('0','1','2','3','4','5','6','7','8','9')
		),
TABLE2 AS (
	SELECT *
	FROM GPOSADM.TABLE2	/* 업체기본정보 */
	WHERE INPUT_DATE BETWEEN TO_CHAR(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -61), 'YYYYMMDD') AND TO_CHAR(SYSDATE + INTERVAL '9' HOUR, 'YYYYMMDD')
	),
_COMM AS (
	SELECT 
		  CORP_GB  -- 코드그룹
		, CODE_ID  -- 코드아이디
		, CODE  -- 코드
		, CONT  -- 코드명
		, LANG_CD  -- 언어코드
	FROM GPOSADM.TABLE4	/* 추가코드정보 */
	WHERE 1=1
		AND LANG_CD = 'KO'
	),
M_부서명 AS (
	SELECT 
		  CORP_GB
		, DEPT_CD
		, MAX(DEPT_NM_EXT) AS DEPT_NM_EXT
	FROM GPOSADM.TABLE5	/* 부서코드(다국어) */
	WHERE 1=1
		AND LANG_CD = 'KO'
	GROUP BY CORP_GB, DEPT_CD
	)
SELECT 
	  CORP_GB_A  -- B_법인구분
	, M_법인명.CORP_NAME -- 법인명
	, VEND_CD  -- A_업체코드
	, VEND_NM_EXT  -- C_업체명(현)
	, VEND_NM_ENG  -- B_업체명(영)
	, VEND_NM_EXT || ' / ' || VEND_NM_ENG AS VEND_NAME
	, TAXPAYR_NO  -- B_사업자등록번호
	, REPR_NM_EXT  -- C_대표자명(현)
	, REPR_NM_ENG  -- B_대표자명(영)
	, REPR_NM_EXT || ' / ' || REPR_NM_ENG AS REPR_NAME
	, REPR_EMAIL  -- B_전자우편
	, TEL_NO  -- B_전화번호
	, VEND_ADDR1_EXT  -- C_주소1(현)
	, VEND_ADDR2_EXT  -- C_주소2(현)  
	, VEND_ADDR1_EXT || ' ' || VEND_ADDR2_EXT AS VEND_ADDR_EXT  
	, VEND_ADDR1_ENG  -- B_주소1(영)
	, VEND_ADDR2_ENG  -- B_주소2(영)
	, VEND_ADDR3_ENG  -- B_주소3(영)
	, VEND_ADDR1_ENG || ' ' || VEND_ADDR2_ENG || ' ' || VEND_ADDR3_ENG AS VEND_ADDR_ENG  
	, CORP_REGST_NO  -- B_법인등록번호
	, VEND_CTRY_CD  -- B_국가
	, M_국가명.NATIONAL_NAME
	, CITY_CD  -- B_지역(도시)
	, M_도시명.CITY_NAME  
	, EMP_CNT_OFFC + EMP_CNT_PROD + EMP_CNT_STUDY + EMP_CNT_PROF + EMP_CNT_MGT + EMP_CNT_UND AS EMP_CNT -- B_종업원
	, INDS_STAT_EXT  -- C_업태(현)
	, INDS_CLASS_EXT  -- C_종목(현)
	, ITEM_NM_EXT  -- C_품목(현)
	, INDS_STAT_ENG  -- B_업태(영)
	, INDS_CLASS_ENG  -- B_종목(영)
	, ITEM_NM_ENG  -- B_품목(영)
	, M_부품명_현.ITEM_NM_ENG1 --KEY_부품명_현  
	, M_부품명_영.ITEM_NM_EXT1 --부품명(영)  
	, REPR_TAXNO  -- B_통합사업자여부
	, COM_SCAL  -- B_회사규모
	, M_회사규모명.SCAL_NAME
	, VEND_TYPE  -- A_업체구분
	, M_업체구분명.VEND_TYPE_NAME  
	, VEND_FORM_GB  -- A_업체유형
	, M_업체유형명.VEND_FORM_NAME     
	, REGST_DEPT_CD_B  -- B_관리부서
	, CASE WHEN M_부서명_B.DEPT_NM_EXT IS NULL THEN CORP_GB_B || REGST_DEPT_CD_B ELSE M_부서명_B.DEPT_NM_EXT END AS MNGT_DEPT_NM
	, PURCH_STOP_YN  -- A_일시정지여부
	, M_일시정지.PURCH_STOP_NAME
	, REGST_DEPT_CD_A  -- A_관리부서
	, M_부서명_A.DEPT_NM_EXT AS REGST_DEPT_NM  -- CORP_GB&DEPT_CD DEPT_NM_EXT
	, TO_DATE(MODI_DATE,'YYYYMMDD') + INTERVAL '9' HOUR AS MODI_DATE  -- A_사용구분변경일		-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, TO_DATE(INPUT_DATE,'YYYYMMDD') + INTERVAL '9' HOUR AS INPUT_DATE -- B_등록일  			-- Tableau 추출 표준시간대 맞추기 위해 + 9시간
	, CASE WHEN TO_DATE(INPUT_DATE, 'YYYYMMDD') + INTERVAL '9' HOUR >= TRUNC(ADD_MONTHS(SYSDATE + INTERVAL '9' HOUR, -60),'MM')
		   THEN 'TRUE' 
		   ELSE 'FALSE'
		   END AS "추출필터"
--	   추가 데이터 로드 24.01.29 (김태식 책임님 요청)
	, SUMUP_REGN -- 대금계상지
	, BIZ_CLASS_CD -- 업종코드
	, VEND_FORM -- 업체형태
	, FIRM_TPIS_CD -- 업체업종  
	, REPR_SCH_EXT -- 대표자 최종학력
	, REPR_CARR1_EXT -- 대표자 주요경력1
	, REPR_CARR2_EXT -- 대표자 주요경력2
	, MANAGE_FORM_CONT1_EXT -- 경영형태내용1
	, MANAGE_FORM_CONT2_EXT -- 경영형태내용2  
	, VEND_NM_SHORT -- 약어
	, ZIP_CD -- 우편번호
	, FAX_NO -- 팩스번호
	, HOME_PAGE -- 홈페이지주소
	, REPR_SCH_ENG -- 대표자 최종학력(영)
	, REPR_CARR1_ENG -- 대표자 주요경력1(영)
	, REPR_CARR2_ENG -- 대표자 주요경력2(영)
	, REPR_BIRTH_DATE -- 대표자 생년월일
	, DUNS_NO	-- Duns Number
	, MANAGE_FORM_CD	-- 경영형태
	, MANAGE_FORM_CONT1_ENG	-- 경영형태내용1(영)
	, MANAGE_FORM_CONT2_ENG	-- 경영형태내용2(영)
	, OPEN_DATE	-- 개업일
	, COM_FORM_CD	-- 회사형태
FROM (
	SELECT
		  T_COMP_BASIC.CORP_GB_A	-- 법인구분 -- 등록법인을 가져오기위한 컬럼 24.02.22
		, T_COMP_BASIC.VEND_CD  -- 업체코드
		, T_COMP_BASIC.VEND_TYPE  -- 업체구분
		, T_COMP_BASIC.VEND_FORM_GB  -- 업체유형
		, T_COMP_BASIC.REGST_DEPT_CD_A -- 관리부서
		, T_COMP_BASIC.PURCH_STOP_YN  -- 일시정지여부
		, T_COMP_BASIC.MODI_DATE  -- 사용구분변경일  
		, T_COMP_BASIC.SUMUP_REGN -- 대금계상지
		, T_COMP_BASIC.BIZ_CLASS_CD -- 업종코드
		, T_COMP_BASIC.VEND_FORM -- 업체형태
		, T_COMP_BASIC.FIRM_TPIS_CD -- 업체업종
		, T2.REGST_DEPT_CD_B
		, T2.CORP_GB_B
		, T3.VEND_NM_ENG  -- 업체명(영)
		, T3.TAXPAYR_NO  -- 사업자등록번호
		, T3.REPR_NM_ENG  -- 대표자명(영)
		, T3.REPR_EMAIL  -- 전자우편
		, T3.TEL_NO  -- 전화번호
		, T3.VEND_ADDR1_ENG  -- 주소1(영)
		, T3.VEND_ADDR2_ENG  -- 주소2(영)
		, T3.VEND_ADDR3_ENG  -- 주소3(영)
		, T3.CORP_REGST_NO  -- 법인등록번호
		, T3.VEND_CTRY_CD  -- 국가
		, T3.CITY_CD  -- 지역(도시)
		, T3.EMP_CNT_OFFC
		, T3.EMP_CNT_PROD
		, T3.EMP_CNT_STUDY
		, T3.EMP_CNT_PROF
		, T3.EMP_CNT_MGT
		, T3.EMP_CNT_UND
		, T3.INDS_STAT_ENG  -- 업태(영)
		, T3.INDS_CLASS_ENG  -- 종목(영)
		, T3.ITEM_NM_ENG  -- 품목(영)
		, T3.REPR_TAXNO  -- 통합사업자여부
		, T3.COM_SCAL  -- 회사규모
		, T3.INPUT_DATE  -- 등록일
		, T3.VEND_NM_SHORT -- 약어
		, T3.ZIP_CD -- 우편번호
		, T3.FAX_NO -- 팩스번호
		, T3.HOME_PAGE -- 홈페이지주소
		, T3.REPR_SCH_ENG -- 대표자 최종학력(영)
		, T3.REPR_CARR1_ENG -- 대표자 주요경력1(영)
		, T3.REPR_CARR2_ENG -- 대표자 주요경력2(영)
		, T3.REPR_BIRTH_DATE -- 대표자 생년월일
		, T3.DUNS_NO	-- Duns Number
		, T3.MANAGE_FORM_CD	-- 경영형태
		, T3.MANAGE_FORM_CONT1_ENG	-- 경영형태내용1(영)
		, T3.MANAGE_FORM_CONT2_ENG	-- 경영형태내용2(영)
		, T3.OPEN_DATE	-- 개업일
		, T3.COM_FORM_CD	-- 회사형태
		, T4.VEND_NM_EXT  -- 업체명(현)
		, T4.REPR_NM_EXT  -- 대표자명(현)
		, T4.VEND_ADDR1_EXT  -- 주소1(현)
		, T4.VEND_ADDR2_EXT  -- 주소2(현)
		, T4.INDS_STAT_EXT  -- 업태(현)
		, T4.INDS_CLASS_EXT  -- 종목(현)
		, T4.ITEM_NM_EXT  -- 품목(현)
		, T4.LANG_CD
		, T4.REPR_SCH_EXT -- 대표자 최종학력
		, T4.REPR_CARR1_EXT -- 대표자 주요경력1
		, T4.REPR_CARR2_EXT -- 대표자 주요경력2
		, T4.MANAGE_FORM_CONT1_EXT -- 경영형태내용1
		, T4.MANAGE_FORM_CONT2_EXT -- 경영형태내용2
	------------------------------------------------------------------------------ A
	FROM T_COMP_BASIC 
	LEFT JOIN (
		SELECT	
--			  CORP_GB || VEND_CD AS KEY	--TABLE2 테이블 CORP_GB을 가져오기위해 Key 필드 생성 24. 02.19
			  CORP_GB
			, VEND_CD
		FROM TABLE2  
		WHERE 1=1
			AND STAT <> 'D'
	) T1 
	ON T_COMP_BASIC.VEND_CD = T1.VEND_CD
	LEFT JOIN ( ---------------------------------------- 24.02.22 관리부서/관리부서명 추출을 위한 테이블 재사용 
		SELECT
--			  (CORP_GB_A || VEND_CD) AS KEY
			  REGST_DEPT_CD_A AS REGST_DEPT_CD_B
			, CORP_GB_A AS CORP_GB_B
			, VEND_CD
		FROM T_COMP_BASIC 
	) T2
	ON  T1.CORP_GB = T2.CORP_GB_B
	AND T1.VEND_CD = T2.VEND_CD
	------------------------------------------------------------------------------ B
	INNER JOIN (
		SELECT 
			  VEND_CD  -- 업체코드
			, VEND_NM_ENG  -- 업체명(영)
			, TAXPAYR_NO  -- 사업자등록번호
			, REPR_NM_ENG  -- 대표자명(영)
			, REPR_EMAIL  -- 전자우편
			, TEL_NO  -- 전화번호
			, VEND_ADDR1_ENG  -- 주소1(영)
			, VEND_ADDR2_ENG  -- 주소2(영)
			, VEND_ADDR3_ENG  -- 주소3(영)
			, CORP_REGST_NO  -- 법인등록번호
			, VEND_CTRY_CD  -- 국가
		--	, VEND_CTRY_CD  -- 국가명
			, CITY_CD  -- 지역(도시)
		--	, CITY_CD  -- 도시명
		--	, EMP_CNT~6개계산값  -- 종업원
			, NVL(EMP_CNT_OFFC,0)  AS EMP_CNT_OFFC
			, NVL(EMP_CNT_PROD,0) AS EMP_CNT_PROD
			, NVL(EMP_CNT_STUDY,0) AS EMP_CNT_STUDY
			, NVL(EMP_CNT_PROF,0) AS EMP_CNT_PROF
			, NVL(EMP_CNT_MGT,0) AS EMP_CNT_MGT
			, NVL(EMP_CNT_UND,0) AS EMP_CNT_UND
			, INDS_STAT_ENG  -- 업태(영)
			, INDS_CLASS_ENG  -- 종목(영)
			, ITEM_NM_ENG  -- 품목(영)
			, REPR_TAXNO  -- 통합사업자여부
			, COM_SCAL  -- 회사규모
		--	, COM_SCAL  -- 회사규모명
		-- 	, REGST_DEPT_CD AS REGST_DEPT_CD_B   -- 등록부서 24.02.22 	위의 선행 JOIN 작업에서 이미 컬럼 사용
		--	, REGST_DEPT_CD  -- 등록부서명
			, INPUT_DATE  -- 등록일
			, VEND_NM_SHORT -- 약어
			, ZIP_CD -- 우편번호
			, FAX_NO -- 팩스번호
			, HOME_PAGE -- 홈페이지주소
			, REPR_SCH_ENG -- 대표자 최종학력(영)
			, REPR_CARR1_ENG -- 대표자 주요경력1(영)
			, REPR_CARR2_ENG -- 대표자 주요경력2(영)
			, REPR_BIRTH_DATE -- 대표자 생년월일
			, DUNS_NO	-- Duns Number
			, MANAGE_FORM_CD	-- 경영형태
			, MANAGE_FORM_CONT1_ENG	-- 경영형태내용1(영)
			, MANAGE_FORM_CONT2_ENG	-- 경영형태내용2(영)
			, OPEN_DATE	-- 개업일
			, COM_FORM_CD	-- 회사형태
		FROM TABLE2
	) T3
	ON T_COMP_BASIC.VEND_CD = T3.VEND_CD
	------------------------------------------------------------------------------ C
	LEFT JOIN (
		SELECT  
			  VEND_CD  -- 업체코드
			, VEND_NM_EXT  -- 업체명(현)
			, REPR_NM_EXT  -- 대표자명(현)
			, VEND_ADDR1_EXT  -- 주소1(현)
			, VEND_ADDR2_EXT  -- 주소2(현)
			, INDS_STAT_EXT  -- 업태(현)
			, INDS_CLASS_EXT  -- 종목(현)
			, ITEM_NM_EXT  -- 품목(현)
			, LANG_CD
			, REPR_SCH_EXT -- 대표자 최종학력
			, REPR_CARR1_EXT -- 대표자 주요경력1
			, REPR_CARR2_EXT -- 대표자 주요경력2
			, MANAGE_FORM_CONT1_EXT -- 경영형태내용1
			, MANAGE_FORM_CONT2_EXT -- 경영형태내용2
		FROM GPOSADM.TABLE3	/* 업체기본정보_다국어_공통정보 */
		WHERE 1=1
			AND LANG_CD = 'KO'
	) T4
	ON T_COMP_BASIC.VEND_CD = T4.VEND_CD
) F
/*----------------------------------- 마스터 공통 -----------------------------------*/
LEFT JOIN (
	SELECT 
		  CODE AS CORP_GB
		, CONT AS CORP_NAME
	FROM _COMM
	WHERE CODE_ID = 'CORP_CD'
	) M_법인명
ON F.CORP_GB_A = M_법인명.CORP_GB 	-- ApplyMap('M_법인명', CORP_GB_A) AS CORP_NAME
LEFT JOIN (
	SELECT 
		  CODE AS KEY_국가
		, CONT AS NATIONAL_NAME
	FROM _COMM
	WHERE CODE_ID = 'CTRY_CD'
	) M_국가명
ON F.VEND_CTRY_CD = M_국가명.KEY_국가 	-- ApplyMap('M_국가명', CORP_GB_A) AS NATIONAL_NAME  *** Qlik에서는 Join Key가 CORP_GB_A(법인코드)로 되어있었으나 태블로 이관 작업 시 VEND_CTRY_CD로 변경 
LEFT JOIN (
	SELECT 
		  CODE AS KEY_회사규모
		, CONT AS SCAL_NAME
	FROM _COMM
	WHERE CODE_ID = 'COM_SCAL'
	) M_회사규모명
ON F.COM_SCAL = M_회사규모명.KEY_회사규모 	-- ApplyMap('M_회사규모명', COM_SCAL) AS SCAL_NAME 
LEFT JOIN (
	SELECT 
		  CODE AS KEY_업체구분
		, CONT AS VEND_TYPE_NAME
	FROM _COMM
	WHERE CODE_ID = 'VEND_TYPE'
	) M_업체구분명
ON F.VEND_TYPE = M_업체구분명.KEY_업체구분	-- ApplyMap('M_업체구분명', VEND_TYPE) AS VEND_TYPE_NAME
LEFT JOIN (
	SELECT 
		  CODE AS KEY_업체유형
		, CONT AS VEND_FORM_NAME
	FROM _COMM
	WHERE CODE_ID = 'VEND_FORM_GB'
	) M_업체유형명
ON F.VEND_FORM_GB = M_업체유형명.KEY_업체유형		-- ApplyMap('M_업체유형명', VEND_FORM_GB) AS VEND_FORM_NAME
LEFT JOIN (
	SELECT 
		  CODE AS KEY_일시정지
		, CONT AS PURCH_STOP_NAME
	FROM _COMM
	WHERE CODE_ID = 'PURCH_STOP_YN'
	) M_일시정지
ON F.PURCH_STOP_YN = M_일시정지.KEY_일시정지		-- ApplyMap('M_일시정지', PURCH_STOP_YN) AS PURCH_STOP_NAME
/*----------------------------------- 마스터 업체 -----------------------------------*/
LEFT JOIN (
	SELECT 
		  CODE AS KEY_도시
		, CONT AS CITY_NAME 
	FROM GPOSADM.TABLE6	/* 기본코드정보 */
	WHERE 1=1
		AND CODE_ID = 'CITY_CD' 
		AND LANG_CD = 'KO'
	) M_도시명
ON F.CITY_CD = M_도시명.KEY_도시		-- ApplyMap('M_도시명', CITY_CD) AS CITY_NAME
LEFT JOIN (
	SELECT 
		  VEND_CD  AS KEY_부품명_현
		, ITEM_NM_ENG1  -- 부품명(현)
	FROM GPOSADM.TABLE7	/* 주요생산품목관리 */
	WHERE 1=1
		AND STAT IN ('C','R')
	) M_부품명_현
ON F.VEND_CD = M_부품명_현.KEY_부품명_현	-- ApplyMap('M_부품명_현', VEND_CD) AS ITEM_NM_ENG1
LEFT JOIN (
	SELECT 
		  VEND_CD AS KEY_부품명_영
		, ITEM_NM_EXT1  -- 부품명(영)
	FROM GPOSADM.TABLE8	/* 주요생산품목관리_다국어 */
	WHERE 1=1
		AND LANG_CD = 'KO'
	) M_부품명_영
ON F.VEND_CD = M_부품명_영.KEY_부품명_영	-- ApplyMap('M_부품명_영', VEND_CD) AS ITEM_NM_EXT1
LEFT JOIN (
	SELECT 
		  CORP_GB
		, DEPT_CD
		, DEPT_NM_EXT
	FROM M_부서명
	) M_부서명_B
ON F.CORP_GB_B = M_부서명_B.CORP_GB
AND F.REGST_DEPT_CD_B = M_부서명_B.DEPT_CD	-- ApplyMap('M_부서명',CORP_GB_B&REGST_DEPT_CD_B) AS MNGT_DEPT_NM  -- CORP_GB&DEPT_CD DEPT_NM_EXT
LEFT JOIN (
	SELECT 
		  CORP_GB
		, DEPT_CD
		, DEPT_NM_EXT
	FROM M_부서명
	) M_부서명_A
ON F.CORP_GB_A = M_부서명_A.CORP_GB
AND F.REGST_DEPT_CD_A = M_부서명_A.DEPT_CD	-- ApplyMap('M_부서명',CORP_GB_A&REGST_DEPT_CD_A) AS REGST_DEPT_NM  -- CORP_GB&DEPT_CD DEPT_NM_EXT
