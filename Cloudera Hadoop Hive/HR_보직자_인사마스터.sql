/*------------------------------------ 0_인사마스터 -----------------------------------
 * 기준 테이블
-----------------------------------------------------------------------------------*/
WITH HR_TEMP AS (
	SELECT
		  HR_B.*
		, ZHHRT9318.`본부조직명`
		, ZHHRT9318.`사업부명`
		, ZHHRT9318.`실명`
		, ZHHRT9318.`중심조직명`
	FROM (
		SELECT 
			  HR.Key AS `%인사PKey`
			, CONCAT(HR.t_1,'|',HR.t_31) AS `%조직PKey`
			, CONCAT(HR.t_1,'|',HR.t_25) AS `직위Pkey`
			, CONCAT(HR.t_1,'|',HR.t_25) AS `경력인정.직위Pkey`
			, CONCAT(HR.t_1,'|',HR.t_27) AS `근무지Pkey`
			, CONCAT(HR.t_1,'|',HR.t_2,'|',HR.t_153,'|',HR.t_151) AS `직무직종상세키`		-- 인재검색에만 있음
			, HR.t_1 AS `클라이언트`
			, Z014.t_2 AS `회사명`
			, HR.t_2 AS `사원 번호`
			, HR.t_3 AS `고객별상태`
			, HR.t_4 AS `인원수`
			, HR.t_5 AS `퇴직자수`
			, HR.t_6 AS `재직/퇴직`
			, HR.t_7 AS `휴직여부`
			, HR.last_name AS `Last Name`
			, HR.first_name AS `First Name`
			, HR.name AS `Name`
			, HR.t_8 AS `성별코드`
			, HR.t_9 AS `성별`
			, HR.t_10 AS `생년월일`
			, HR.t_11 AS `국적코드`
			, HR.t_12 AS `국적`
			, HR.t_13 AS `결혼여부`
			, HR.t_14 AS `출신도코드`
			, HR.t_15 AS `출신도`
			, HR.t_16 AS `성(한자)`
			, HR.t_17 AS `이름(한자)`
			, HR.t_18 AS `한글이름`
			, HR.t_19 AS `성명`
		-- 	, HR.t_20 AS `조직키`
			, HR.t_21 AS `직군코드`
			, HR.t_22 AS `담당조직등급코드`
			, HR.t_23 AS `보직유무코드`
			, HR.t_24 AS `직책코드`
			, HR.t_25 AS `직위코드`
			, HR.t_26 AS `시스템.근무지코드`
			, HR.t_27 AS `시스템.상세근무지역코드`
			, HR.t_28 AS `시스템.직무코드`
			, HR.t_29 AS `포지션코드`
			, HR.t_30 AS `조직 단위`
			, HR.t_31 AS `조직코드`
			, HR.t_32 AS `인사 영역`
			, HR.t_33 AS `인사영역명`
			, HR.t_34 AS `시스템.직군코드`
			, HR.t_35 AS `시스템.직군`
			, HR.t_36 AS `급여형태코드`
			, HR.t_37 AS `급여형태`
			, HR.t_38 AS `급여계산영역코드`
			, HR.t_39 AS `급여계산영역`
			, HR.t_40 AS `조직`
			, HR.t_41 AS `포지션`
			, HR.t_42 AS `시스템.직무`
			, HR.t_43 AS `시스템.근무지`
			, HR.t_44 AS `시스템.상세근무지`
			, HR.t_45 AS `시스템.직위`
			, HR.t_46 AS `직책`
			, HR.t_47 AS `보직유무`
			, HR.t_48 AS `담당조직등급_구`	-- `담당조직등급`
			, CASE WHEN HR.t_48 IN ('부사장','본부')	THEN '본부장급'
				   WHEN HR.t_48 = '사업부'			THEN '사업부장급'
				   WHEN HR.t_48 = '실'				THEN '실장급'
				   WHEN HR.t_48 IN ('부','팀')		THEN '팀장급'
			  END AS `담당조직등급`
			, HR.t_49 AS `직군`
		--	, HR.t_50 AS `실거주지.우편번호`
		--	, HR.t_51 AS `실거주지.지역명`
		--	, HR.t_52 AS `실거주지.시`
		--	, HR.t_53 AS `실거주지.지역`
		--	, HR.t_54 AS `실거주지.주소`
			, HR.t_55 AS `회사입사일`
			, HR.t_56 AS `장기근속기준일`
			, HR.t_57 AS `현직승진일`
			, HR.t_58 AS `경력인정일`
			, HR.t_59 AS `승진기준일`
		--	, HR.t_60 AS `승급기준일`
			, HR.t_61 AS `현부서발령일`
			, HR.t_62 AS `그룹입사일`
			, HR.t_63 AS `고용형태코드`
			, HR.t_64 AS `입사형태코드`
			, HR.t_65 AS `채용채널코드`
			, HR.t_66 AS `경력인정직위코드`
			, HR.t_67 AS `희망부문코드`
			, HR.t_68 AS `희망분야코드`
			, HR.t_69 AS `입사구분코드`
			, HR.t_70 AS `입사근거코드`
			, HR.t_71 AS `채용직군코드`
			, HR.t_72 AS `채용직군`
			, HR.t_73 AS `초임구분코드`
			, HR.t_74 AS `초임구분`
		 	, HR.t_75 AS `희망부문`
			, HR.t_76 AS `구.사번`
		-- 	, HR.t_77 AS `회사구분`
			, HR.t_78 AS `채용시스템ID`
			, HR.t_79 AS `입사정보.퇴직내용`
			, HR.t_80 AS `공채기수`
			, HR.t_81 AS `암호화된비밀번호`
			, HR.t_82 AS `입사근거`
			, HR.t_83 AS `입사구분`
		 	, HR.t_84 AS `희망분야`
			, HR.t_85 AS `경력인정직위`
			, HR.t_86 AS `채용채널`
			, HR.t_87 AS `입사형태`
			, HR.t_88 AS `고용형태`
			, HR.t_89 AS `계약종료예정일`
			, HR.t_90 AS `주재원.포지션`
			, HR.t_91 AS `해외직종`
			, HR.t_92 AS `근무도시`
			, HR.t_93 AS `지사코드`
			, HR.t_94 AS `주재구분`
			, HR.t_95 AS `주재구분명`
			, HR.t_96 AS `피부양자동반여부`
			, HR.t_97 AS `지사담당여부`
			, HR.t_98 AS `복귀예정일`
			, HR.t_99 AS `최초부임일`
			, HR.t_100 AS `관리지사코드`
			, HR.t_101 AS `관리지사코드2`
			, HR.t_102 AS `관리지사코드3`
			, HR.t_103 AS `주재원.지사명`
			, HR.t_104 AS `주재원.근무도시명`
			, HR.t_105 AS `주재원.국가키`
			, HR.t_106 AS `주재원.근무국가`
			, HR.t_107 AS `해외직종명`
			, HR.t_108 AS `주재원포지션명`
			, HR.t_109 AS `고등학교`
			, HR.t_110 AS `대학교`
			, HR.t_111 AS `고등학교전공`
			, HR.t_112 AS `대학교전공`
			, HR.t_113 AS `대학교전공계열`
			, HR.t_114 AS `인정학력코드`
			, HR.t_115 AS `인정학력`
			, HR.t_116 AS `인정학교전공`
			, HR.t_117 AS `인정학교전공계열`
			, HR.t_118 AS `인정학교`
			, HR.t_119 AS `최종학력코드`
			, HR.t_120 AS `최종학력`
			, HR.t_121 AS `최종학교전공`
			, HR.t_122 AS `최종학교전공계열`
			, HR.t_123 AS `최종학교`
		--	, HR.t_124 AS `사외경력.직종`
		--	, HR.t_125 AS `사외경력.대기업군코드`
		--	, HR.t_126 AS `사외경력.업종코드`
		--	, HR.t_127 AS `사외경력.회사코드`
		--	, HR.t_128 AS `사외경력.회사`
		--	, HR.t_129 AS `사외경력.회사명(대표)`
		--	, HR.t_130 AS `사외경력.업종`
		--	, HR.t_131 AS `사외경력.대기업군명`
		--	, HR.t_132 AS `사외경력.직종명`
			, HR.t_133 AS `휴직사유코드`
			, HR.t_134 AS `휴직유형`
			, HR.t_135 AS `휴직사유`
			, HR.t_136 AS `장애유형`
			, HR.t_137 AS `장애등급`
			, HR.t_138 AS `고용부담금대상`
			, HR.t_139 AS `고용부담금 시작년월`
			, HR.t_140 AS `고용부담금 종료년월`
			, HR.t_141 AS `장애유형명`
			, HR.t_142 AS `퇴직기본.종료일`
			, HR.t_143 AS `퇴직목적`
			, HR.t_144 AS `퇴직사유`
			, HR.t_145 AS `퇴직일`
			, HR.t_146 AS `퇴직유형`
			, HR.t_147 AS `퇴직내용`
			, HR.t_148 AS `퇴직사유명`
			, HR.t_149 AS `퇴직목적명`
			, HR.t_150 AS `직종코드`
			, HR.t_151 AS `직종`
			, HR.t_152 AS `직무코드`
			, HR.t_153 AS `직무`
			, HR.t_154 AS `작업일자`
		-- 	, HR.t_155 AS `PAYGRADE시작일`
		-- 	, HR.t_156 AS `연구직 PAY GRADE`
		--	, HR.t_157 AS `연구직 비고`
			, YEAR(HR.`작업일자(YYMMDD)`) AS `YEAR`
			, YEAR(HR.`회사입사일(YYMMDD)`) AS `회사입사연도`			-- 인재검색에만 있음
			, HR.`생년월일(YYMMDD)`
			, HR.`회사입사일(YYMMDD)`
			, DATEDIFF(HR.`작업일자(YYMMDD)`,HR.`회사입사일(YYMMDD)`) AS `근속일수(회사입사일)`
			, YEAR(HR.`회사입사일(YYMMDD)`) AS `회사입사년도`
			, MONTH(HR.`회사입사일(YYMMDD)`) AS `회사입사월`
			, HR.`장기근속기준일(YYMMDD)`
			, FLOOR(DATEDIFF(HR.`작업일자(YYMMDD)`,HR.`장기근속기준일(YYMMDD)`) / 365.25) AS `근속년수(장기근속기준일)`
			, DATEDIFF(HR.`작업일자(YYMMDD)`,HR.`장기근속기준일(YYMMDD)`) AS `근속일수(장기근속기준일)`
			, HR.`현직승진일(YYMMDD)`
			, HR.`경력인정일(YYMMDD)`
			, HR.`승진기준일(YYMMDD)`
			, HR.`승급기준일(YYMMDD)`
			, HR.`현부서발령일(YYMMDD)`
			, FLOOR(DATEDIFF(HR.`작업일자(YYMMDD)`,HR.`현부서발령일(YYMMDD)`) / 365.25) AS `조직체류연한_핵심인재`
			, HR.`그룹입사일(YYMMDD)`
			, CASE WHEN HR.`회사입사일(YYMMDD)` < HR.`그룹입사일(YYMMDD)`
				   THEN FLOOR(DATEDIFF(HR.`작업일자(YYMMDD)`,HR.`회사입사일(YYMMDD)`) / 365.25)
				   ELSE FLOOR(DATEDIFF(HR.`작업일자(YYMMDD)`,HR.`그룹입사일(YYMMDD)`) / 365.25)
			  END AS `근속년수_핵심인재`
			, HR.`계약종료예정일(YYMMDD)`
			, HR.`복귀예정일(YYMMDD)`
			, HR.`최초부임일(YYMMDD)`
			, HR.`퇴직기본.종료일(YYMMDD)`
			, HR.`퇴직일(YYMMDD)`
			, HR.`작업일자(YYMMDD)`
		-- 	, B.t_1 AS `클라이언트`
		-- 	, B.t_2 AS `일자`
		-- 	, B.t_3 AS `사원 번호`
		-- 	, B.t_4 AS `사원 번호2`
			, B.t_5 AS `주민등록번호(앞6자리)`
			, B.t_6 AS `병역관계`
			, B.t_7 AS `병역관계명`
			, B.t_8 AS `보훈여부`
			, B.t_9 AS `조합`
			, B.t_10 AS `인사.보직임명일자`	-- `보직임명일자`
			, B.t_11 AS `수습여부`
		-- 	, B.t_12 AS `보직유무`
			, CASE WHEN B.t_12 = '#' THEN '팀장급이상' 
				   WHEN B.t_12 = ' ' THEN '비보직' 
				   ELSE '팀장급미만' 
			  END AS `보직(최장우)`
		-- 	, B.t_13 AS `보직유무명`
			, B.t_14 AS `보직등급`
			, B.t_15 AS `인사.조직등급명칭`	-- `조직등급명칭`
		-- 	, B.t_16 AS `직책`
		-- 	, B.t_17 AS `직책명`
		 	, B.t_18 AS `근속기준일`
			, B.t_19 AS `휴직중구분`
			, B.t_20 AS `정직중구분`
			, B.t_21 AS `파견중구분`
			, B.t_22 AS `상근비상근여부`
			, B.t_23 AS `근속년`
			, CAST(TRIM(B.t_23) AS INT) AS `근속년수`
			, B.t_24 AS `근속월`
			, CAST(TRIM(B.t_25) AS INT) AS `승진년차`
		-- 	, B.t_26 AS `장기근속기준일`
			, B.t_27 AS `연구직 연차진행일`
			, CAST(TRIM(B.t_28) AS INT) AS `연구직 승급연차`
		-- 	, B.t_29 AS `휴직사유`
		-- 	, B.t_30 AS `휴직사유명칭`
			, B.t_31 AS `겸직여부`
			, B.t_32 AS `후 겸직부서(말단조직)`
		 	, B.t_33 AS `당사입사일`
			, B.t_34 AS `장기근속기준일2`
			, B.t_35 AS `내역`
		-- 	, B.t_36 AS `퇴직사유`
		-- 	, B.t_37 AS `퇴직사유명`
		-- 	, B.t_38 AS `퇴직목적`
		-- 	, B.t_39 AS `퇴직목적명`
		-- 	, B.t_40 AS `퇴직내용`
			, B.t_41 AS `[HR]핵심인재 종류`
			, B.t_42 AS `[HR]내역길이 30`
		-- 	, B.t_43 AS `채용직군`
		 	, B.t_44 AS `사원 그룹 이름`
		 	, B.t_45 AS `채용지역`
		 	, B.t_46 AS `채용지역명`
		-- 	, B.t_47 AS `초임구분`
		 	, B.t_48 AS `초임구분2`
		-- 	, B.t_49 AS `희망부문`
		-- 	, B.t_50 AS `희망부문명`
		-- 	, B.t_51 AS `희망분야`
		-- 	, B.t_52 AS `희망분야명`
			, B.t_53 AS `영어점수`
			, B.t_54 AS `영어시험명`
			, B.t_55 AS `영어 최고점수`
			, B.t_56 AS `영어 인정점수`
			, B.t_57 AS `중국어점수`
			, B.t_58 AS `중국어시험명`
			, B.t_59 AS `중국어 최고점수`
			, B.t_60 AS `중국어 인정점수`
			, B.t_61 AS `기타외국어 점수`
			, B.t_62 AS `기타외국어 시험명`
			, B.t_63 AS `기타외국어 최고점수`
			, B.t_64 AS `기타외국어 인정점수`
			, B.t_65 AS `보직수행기간.준팀급`
			, B.t_66 AS `보직수행기간.팀급`
			, B.t_67 AS `보직수행기간.실급`
			, B.t_68 AS `보직수행기간.사업부급`
			, B.t_69 AS `보직수행기간.본부급`
		-- 	, B.t_70 AS `최종 변경일`
		-- 	, B.t_71 AS `오브젝트 변경자 이름`
		-- 	, B.t_72 AS `변경 시간`
		-- 	, B.t_73 AS `작업일자`
			, B.`보직임명일자(YYMMDD)`
			, B.`근속기준일(YYMMDD)`
			, B.`연구직 연차진행일(YYMMDD)`
			, B.`장기근속기준일2(YYMMDD)`
			, FLOOR(DATEDIFF(B.`작업일자(YYMMDD)`,B.`주민등록번호(앞8자리)`) / 365.25) AS `만 나이`
			, FLOOR(DATEDIFF(B.`작업일자(YearEnd)`,B.`주민등록번호(앞8자리)`) / 365.25) AS `만 나이(12/31기준)`
		FROM (
		/*----------------------- 인사마스터 --------------------------*/
			SELECT 
				  *
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_10), '.', '-'), 'yyyy-M-d'))) AS `생년월일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_55), '.', '-'), 'yyyy-M-d'))) AS `회사입사일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_56), '.', '-'), 'yyyy-M-d'))) AS `장기근속기준일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_57), '.', '-'), 'yyyy-M-d'))) AS `현직승진일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_58), '.', '-'), 'yyyy-M-d'))) AS `경력인정일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_59), '.', '-'), 'yyyy-M-d'))) AS `승진기준일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_60), '.', '-'), 'yyyy-M-d'))) AS `승급기준일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_61), '.', '-'), 'yyyy-M-d'))) AS `현부서발령일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_62), '.', '-'), 'yyyy-M-d'))) AS `그룹입사일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_89), '.', '-'), 'yyyy-M-d'))) AS `계약종료예정일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_98), '.', '-'), 'yyyy-M-d'))) AS `복귀예정일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_99), '.', '-'), 'yyyy-M-d'))) AS `최초부임일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_142), '.', '-'), 'yyyy-M-d'))) AS `퇴직기본.종료일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_145), '.', '-'), 'yyyy-M-d'))) AS `퇴직일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_154), '.', '-'), 'yyyy-M-d'))) AS `작업일자(YYMMDD)`
			FROM hr_bi.TABLE1
			WHERE 1=1 
				AND t_49 <> '제외'		-- 직군
				AND LENGTH(t_49) > 0	-- 직군
				AND t_25 <> 'Z3'		-- 직위코드
				AND t_6 = '재직'			-- 재직/퇴직
				AND t_48 IN ('부사장','본부','사업부','실','팀','부') -- 담당조직등급
			) HR
/*========================================================================
								클라이언트
========================================================================*/
		LEFT JOIN hr_bi.zhhrtm014 Z014 		-- 클라이언트
		ON HR.t_1 = Z014.t_1
/*========================================================================
									B
========================================================================*/
		LEFT JOIN (
			SELECT 
				  *
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(
				  CASE WHEN trim(t_5) = '' THEN NULL
					   ELSE 
							CASE WHEN CAST(SUBSTR(TRIM(t_5),1,2) AS INT) > CAST(SUBSTR(YEAR(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_73), '.', '-'), 'yyyy-M-d')))),3,2) AS INT)
								 THEN CONCAT('19',t_5)
								 ELSE CONCAT('20',t_5)
								 END 
					   END, 'yyyyMMdd'))) AS `주민등록번호(앞8자리)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_10), '.', '-'), 'yyyy-M-d'))) AS `보직임명일자(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_18), '.', '-'), 'yyyy-M-d'))) AS `근속기준일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_27), '.', '-'), 'yyyy-M-d'))) AS `연구직 연차진행일(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_34), '.', '-'), 'yyyy-M-d'))) AS `장기근속기준일2(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_73), '.', '-'), 'yyyy-M-d'))) AS `작업일자(YYMMDD)`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(CONCAT(SUBSTR(TRIM(t_73),1,4),'1231'), 'yyyyMMdd'))) AS `작업일자(YearEnd)`	-- 작업일자
				, CONCAT(t_1,'|',t_3) AS `%인사PKey`
			FROM hr_bi.TABLE2
			) B
		/*----------------------------------------------------------*/
		ON HR.Key = B.`%인사PKey` 	-- [HR]	Key As %인사PKey		[B] 클라이언트  & '|' & "사원 번호" As %인사PKey
		) HR_B
/*========================================================================
							ZHHRT9318_조직코드
========================================================================*/
	LEFT JOIN (
		SELECT 
			  OC.`작업일자(YYMMDD)` AS `작업일자_New` 
			, YEAR(OC.`작업일자(YYMMDD)`) AS `YEAR`
			, OC.t_110 AS `%조직PKey`	-- `조직키`
			, Z015.`총괄구분`	-- ApplyMap('총괄구분_Map',클라이언트&"총괄여부(총괄직속구분)", OC.'')
			, OC.`총괄구분코드`
		--	, OC.t_1 AS `클라이언트`
		--	, OC.t_2 AS `오브젝트 ID`
			, OC.t_3 AS `일자`
		--	, OC.t_4 AS `오브젝트 약어`
		--	, OC.t_5 AS `오브젝트 이름`
		--	, OC.t_6 AS `영문조직명칭`
		--	, OC.t_7 AS `사원 번호`
			, OC.t_8 AS `보직임명일자`
			, OC.t_9 AS `총괄여부(총괄직속구분)`
			, OC.t_10 AS `출력순위`
			, OC.t_11 AS `트리순위`
			, OC.t_12 AS `정규/임시`
			, OC.t_13 AS `조직등급`
			, OC.t_14 AS `조직등급명칭`
			, OC.t_15 AS `총괄 FLAG`
			, OC.t_16 AS `BI 조직등급`
			, OC.t_17 AS `BI용 조직등급 명칭`
			, OC.t_18 AS `조직계층수`
			, OC.t_19 AS `상급조직`
			, OC.t_20 AS `상급조직코드`
			, OC.t_21 AS `상급조직명`
			, OC.t_22 AS `중심조직`
		--	, OC.t_23 AS `중심조직코드`
			, OC.t_24 AS `중심조직명`
		--	, OC.t_25 AS `영문중심조직명`
			, OC.t_26 AS `중심조직장`
			, OC.t_27 AS `부코드`
			, OC.t_28 AS `부코드2`
			, OC.t_29 AS `실코드`
			, OC.t_30 AS `실코드2`
			, OC.t_31 AS `실명`
		--	, OC.t_32 AS `영문실명`
			, OC.t_33 AS `실장 사원번호`
			, OC.t_34 AS `사업부코드`
			, OC.t_35 AS `사업부코드2`
			, OC.t_36 AS `사업부명`
		--	, OC.t_37 AS `영문사업부명`
			, OC.t_38 AS `사업부장 사원번호`
			, OC.t_39 AS `본부코드`
			, OC.t_40 AS `본부코드2`
			, OC.t_41 AS `본부조직명`
		--	, OC.t_42 AS `영문본부명`
			, OC.t_43 AS `본부장 사원번호`
			, OC.t_44 AS `정원관리 본부코드`
			, OC.t_45 AS `본부사업부`
			, OC.t_46 AS `조직코드1`
			, OC.t_47 AS `조직약어1`
			, OC.t_48 AS `조직명1`
			, OC.t_49 AS `조직코드2`
			, OC.t_50 AS `조직약어2`
			, OC.t_51 AS `조직명2`
			, OC.t_52 AS `조직코드3`
			, OC.t_53 AS `조직약어3`
			, OC.t_54 AS `조직명3`
			, OC.t_55 AS `조직코드4`
			, OC.t_56 AS `조직약어4`
			, OC.t_57 AS `조직명4`
			, OC.t_58 AS `조직코드5`
			, OC.t_59 AS `조직약어5`
			, OC.t_60 AS `조직명5`
			, OC.t_61 AS `조직코드6`
			, OC.t_62 AS `조직약어6`
			, OC.t_63 AS `조직명6`
			, OC.t_64 AS `조직코드7`
			, OC.t_65 AS `조직약어7`
			, OC.t_66 AS `조직명7`
			, OC.t_67 AS `조직코드8`
			, OC.t_68 AS `조직약어8`
			, OC.t_69 AS `조직명8`
			, OC.t_70 AS `조직코드9`
			, OC.t_71 AS `조직약어9`
			, OC.t_72 AS `조직명9`
			, OC.t_73 AS `조직코드10`
			, OC.t_74 AS `조직약어10`
			, OC.t_75 AS `조직명10`
			, OC.t_76 AS `조직코드11`
			, OC.t_77 AS `조직약어11`
			, OC.t_78 AS `조직명11`
			, OC.t_79 AS `조직코드12`
			, OC.t_80 AS `조직약어12`
			, OC.t_81 AS `조직명12`
			, OC.t_82 AS `조직코드13`
			, OC.t_83 AS `조직약어13`
			, OC.t_84 AS `조직명13`
			, OC.t_85 AS `조직코드14`
			, OC.t_86 AS `조직약어14`
			, OC.t_87 AS `조직명14`
			, OC.t_88 AS `조직코드15`
			, OC.t_89 AS `조직약어15`
			, OC.t_90 AS `조직명15`
			, OC.t_91 AS `조직코드16`
			, OC.t_92 AS `조직약어16`
			, OC.t_93 AS `조직명16`
			, OC.t_94 AS `조직코드17`
			, OC.t_95 AS `조직약어17`
			, OC.t_96 AS `조직명17`
			, OC.t_97 AS `조직코드18`
			, OC.t_98 AS `조직약어18`
			, OC.t_99 AS `조직명18`
			, OC.t_100 AS `조직코드19`
			, OC.t_101 AS `조직약어19`
			, OC.t_102 AS `조직명19`
			, OC.t_103 AS `조직코드20`
			, OC.t_104 AS `조직약어20`
			, OC.t_105 AS `조직명20`
		--	, OC.t_106 AS `전체 조직트리`
		--	, OC.t_107 AS `최종 변경일`
		--	, OC.t_108 AS `오브젝트 변경자 이름`
		--	, OC.t_109 AS `시간`
		--	, OC.t_111 AS `조직코드`
			, OC.t_112 AS `기준일자`
			, OC.t_113 AS `조직명`
			, OC.t_114 AS `본부장명`
			, OC.t_115 AS `사업부장명`
			, OC.t_116 AS `실장명`
			, OC.t_117 AS `중심조직장명`
			, OC.t_118 AS `보직자명`
			, OC.t_119 AS `본부장 보직임명일`
			, OC.t_120 AS `사업부장 보직임명일`
			, OC.t_121 AS `실장 보직임명일`
			, OC.t_122 AS `중심조직장 보직임명일`
		--	, OC.t_123 AS `작업일자`
		FROM (
		/*------------------- ZHHRT9318_조직코드 ---------------------*/
			SELECT 
				  *
				, CONCAT(t_1,t_9) AS `총괄구분코드`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_123), '.', '-'), 'yyyy-M-d'))) AS `작업일자(YYMMDD)`
			FROM hr_bi.TABLE3
			) OC
		/*----------------------------------------------------------*/
		LEFT JOIN (
		/*--------------------- 총괄구분_Map -------------------------*/
			SELECT 
				  t_1 AS `소속회사명총괄구분`
				, t_2 AS `총괄구분`
			FROM hr_bi.zhhrtm015	-- 총괄구분_Map
			) Z015
		/*----------------------------------------------------------*/
		ON OC.`총괄구분코드` = Z015.`소속회사명총괄구분`
		) ZHHRT9318
	ON HR_B.`%조직PKey` = ZHHRT9318.`%조직PKey`
	),
HR_MASTER AS (
	SELECT 
		  HT.*
		, ZHHRT9317.`직위Pkey`
		, ZHHRT9317.`직위유형1코드`
		, ZHHRT9317.`직위유형2코드`
		, ZHHRT9317.`직위유형3코드`
		, ZHHRT9317.`직위구분.종료일`
		, ZHHRT9317.`직위구분.시작일`
		, ZHHRT9317.`직위`
		, ZHHRT9317.`Title`
		, ZHHRT9317.`직위유형코드2`
		, ZHHRT9317.`직위유형1`
		, ZHHRT9317.`직위유형2`
		, ZHHRT9317.`직위유형3`
	FROM HR_TEMP HT
	/*========================================================================
								Q2T_ZHHRT9317_직위분류
	========================================================================*/
	LEFT JOIN (
		SELECT 
			  CONCAT(Z9317.t_1,'|',Z9317.t_7) AS `직위Pkey`
		--	, Z9317.t_1 AS `클라이언트`
		--	, Z9317.t_2 AS `언어 키`
		--	, Z9317.t_3 AS `유형코드`
			, Z9317.t_4 AS `직위유형1코드`		-- `대분류코드`
			, Z9317.t_5 AS `직위유형2코드`		-- `중분류코드`
			, Z9317.t_6 AS `직위유형3코드`		-- `소분류코드`
		--	, Z9317.t_7 AS `직위`
			, Z9317.t_8 AS `직위구분.종료일`
			, Z9317.t_9 AS `직위구분.시작일`
			, Z9317.t_10 AS `직위`				-- `직위명 (BI용)`
			, Z9317.t_11 AS `Title`			-- `직위명(영문 BI용)`
			, Z9317.t_12 AS `직위유형코드2`		-- `유형코드2`
			, Z9317.t_13 AS `직위유형1`			-- `대분류코드2`
			, Z9317.t_14 AS `직위유형2`			-- `중분류코드2`
			, Z9317.t_15 AS `직위유형3`			-- `소분류코드2`
		--	, Z9317.t_16 AS `비고`
		--	, Z9317.t_17 AS `회사구분`
		--	, Z9317.t_18 AS `오브젝트가 마지막으로 변경된 날짜`
		--	, Z9317.t_19 AS `사용자 마스터 레코드의 사용자 이름`
		--	, Z9317.t_20 AS `사원 또는 지원자의 포매팅된 이름`
		FROM HR_TEMP H
		INNER JOIN ( -- IntervalMatch (작업일자, 직위Pkey)
		/*------------------ Q2T_ZHHRT9317_직위분류 ------------------*/
			SELECT
				  *
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REGEXP_REPLACE(TRIM(t_9), '\\.\\s*', '-'), 'yyyy-M-d'))) AS `직위구분.시작일`
				, TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REGEXP_REPLACE(TRIM(t_8), '\\.\\s*', '-'), 'yyyy-M-d'))) AS `직위구분.종료일`
			FROM hr_bi.TABLE4
			WHERE 1=1
				AND t_2 = 3		-- 언어 키
				AND t_3 = 10	-- 유형코드
			) Z9317
		/*----------------------------------------------------------*/
		ON  H.`클라이언트` = Z9317.t_1						-- 직위Pkey
		AND H.`직위코드`	= Z9317.t_7						-- 직위Pkey
		AND H.`작업일자(YYMMDD)` BETWEEN Z9317.`직위구분.시작일` AND Z9317.`직위구분.종료일`
		) ZHHRT9317
	ON HT.`직위Pkey` = ZHHRT9317.`직위Pkey`
	),
/*========================================================================
								임원평가3년평균
========================================================================*/
ZHHRT6050_E AS (
	SELECT
		  `사원 번호`
		, AVG(`성과연평균`) AS `임원성과평가3개년평균`
	FROM (
		/*--------------------- 평가3년평균tmp ------------------------*/
		SELECT 
			  SUBSTR(`성과평가Key`,6,8) AS `사원 번호`
			, `성과평가Key`
			, `성과연평균`
		FROM (
			/*----------------------- 연평균평가 --------------------------*/
			SELECT 
				  `성과평가Key`
				, AVG(`성과역량평가점수`) AS `성과연평균`
			FROM (
				/*------------------------ 성과역량 --------------------------*/
				SELECT 
					  CONCAT(t_2,'|',t_6) AS `성과평가Key`
				--	, Key AS `Key`
				--	, t_1 AS `클라이언트`
					, t_2 AS `평가년도` 			-- `대상 년도`
				--	, t_3 AS `평가순서구분`
					, t_4 AS `성과역량.평가구분`		-- `평가구분`
					, t_5 AS `성과역량.평가구분명`	-- `평가구분명`
					, CASE WHEN t_4 = 'C' THEN '역량'
						   WHEN t_4 = 'R' THEN '성과'
						   WHEN t_4 = 'E' THEN '임원'
						   WHEN t_4 = 'S' THEN '상반기'
						   WHEN t_4 = 'H' THEN '하반기'
					  END AS `성과역량.평가구분명(수정)`
					, t_6 AS `사원 번호`			-- `피평가자 사번`
					, t_9 AS `피평가자 직위`
					, t_10 AS `피평가자 직위명`
					, t_19 AS `5등급`
					, CASE WHEN t_19 IN ('O','S') THEN 100
						   WHEN t_19 IN ('E','A') THEN 75
						   WHEN t_19 IN ('M','B') THEN 50
						   WHEN t_19 IN ('N','C') THEN 25
						   WHEN t_19 IN ('U','D') THEN 0
						   ELSE t_19
					  END AS `성과역량평가점수`
				FROM hr_bi.TABLE5
				WHERE 1=1
					AND t_2 IN (2020,2019,2018)	-- 대상 년도
					AND t_4 = 'E'	-- 평가구분
				/*----------------------------------------------------------*/
				) `성과역량`
			GROUP BY `성과역량평가점수`, `성과평가Key`
			/*----------------------------------------------------------*/
			) `연평균평가`
		/*----------------------------------------------------------*/
		) `평가3년평균tmp`
	GROUP BY `사원 번호`
	),
/*========================================================================
								직원평가3년평균
========================================================================*/
ZHHRT6050_CR AS (
	SELECT
		  `사원 번호`
		, AVG(`성과연평균`) AS `책임성과평가3개년평균`
	FROM (
		/*--------------------- 평가3년평균tmp ------------------------*/
		SELECT 
			  SUBSTR(`성과평가Key`,6,8) AS `사원 번호`
			, `성과평가Key`
			, `성과연평균`
		FROM (
			/*----------------------- 연평균평가 --------------------------*/
			SELECT 
				  `성과평가Key`
				, AVG(`성과역량평가점수`) AS `성과연평균`
			FROM (
				/*------------------------ 성과역량 --------------------------*/
				SELECT 
					  CONCAT(t_2,'|',t_6) AS `성과평가Key`
				--	, Key AS `Key`
				--	, t_1 AS `클라이언트`
					, t_2 AS `평가년도` 			-- `대상 년도`
				--	, t_3 AS `평가순서구분`
					, t_4 AS `성과역량.평가구분`		-- `평가구분`
					, t_5 AS `성과역량.평가구분명`	-- `평가구분명`
					, CASE WHEN t_4 = 'C' THEN '역량'
						   WHEN t_4 = 'R' THEN '성과'
						   WHEN t_4 = 'E' THEN '임원'
						   WHEN t_4 = 'S' THEN '상반기'
						   WHEN t_4 = 'H' THEN '하반기'
					  END AS `성과역량.평가구분명(수정)`
					, t_6 AS `사원 번호`			-- `피평가자 사번`
					, t_9 AS `피평가자 직위`
					, t_10 AS `피평가자 직위명`
					, t_19 AS `5등급`
					, CASE WHEN t_19 IN ('O','S') THEN 100
						   WHEN t_19 IN ('E','A') THEN 75
						   WHEN t_19 IN ('M','B') THEN 50
						   WHEN t_19 IN ('N','C') THEN 25
						   WHEN t_19 IN ('U','D') THEN 0
						   ELSE t_19
					  END AS `성과역량평가점수`
				FROM hr_bi.TABLE5
				WHERE 1=1
					AND t_2 IN (2020,2019,2018)	-- 대상 년도
					AND t_4 IN ('C','R')	-- 평가구분
				/*----------------------------------------------------------*/
				) `성과역량`
			GROUP BY `성과역량평가점수`, `성과평가Key`
			/*----------------------------------------------------------*/
			) `연평균평가`
		/*----------------------------------------------------------*/
		) `평가3년평균tmp`
	GROUP BY `사원 번호`
	),
/*========================================================================
							전직급평가3개년평균
========================================================================*/
ZHHRT6050 AS (
	SELECT 
		  `사원 번호`
		, `성과평가3개년평균`
		, CASE WHEN `성과평가3개년평균` >= 75 THEN '상'
			   WHEN `성과평가3개년평균` <= 50 THEN '하'
			   ELSE '중'
		  END AS `성과평가3개년상중하`
	FROM (
		/*-------------------- 평가3년평균tmp1 ------------------------*/
		SELECT
			  `사원 번호`
			, AVG(`성과연평균`) AS `성과평가3개년평균`
		FROM (
			/*--------------------- 평가3년평균tmp ------------------------*/
			SELECT 
				  SUBSTR(`성과평가Key`,6,8) AS `사원 번호`
				, `성과평가Key`
				, `성과연평균`
			FROM (
				/*----------------------- 연평균평가 --------------------------*/
				SELECT 
					  `성과평가Key`
					, AVG(`성과역량평가점수`) AS `성과연평균`
				FROM (
					/*------------------------ 성과역량 --------------------------*/
					SELECT 
						  CONCAT(t_2,'|',t_6) AS `성과평가Key`
					--	, Key AS `Key`
					--	, t_1 AS `클라이언트`
						, t_2 AS `평가년도` 			-- `대상 년도`
					--	, t_3 AS `평가순서구분`
						, t_4 AS `성과역량.평가구분`		-- `평가구분`
						, t_5 AS `성과역량.평가구분명`	-- `평가구분명`
						, CASE WHEN t_4 = 'C' THEN '역량'
							   WHEN t_4 = 'R' THEN '성과'
							   WHEN t_4 = 'E' THEN '임원'
							   WHEN t_4 = 'S' THEN '상반기'
							   WHEN t_4 = 'H' THEN '하반기'
						  END AS `성과역량.평가구분명(수정)`
						, t_6 AS `사원 번호`			-- `피평가자 사번`
						, t_9 AS `피평가자 직위`
						, t_10 AS `피평가자 직위명`
						, t_19 AS `5등급`
						, CASE WHEN t_19 IN ('O','S') THEN 100
							   WHEN t_19 IN ('E','A') THEN 75
							   WHEN t_19 IN ('M','B') THEN 50
							   WHEN t_19 IN ('N','C') THEN 25
							   WHEN t_19 IN ('U','D') THEN 0
							   ELSE t_19
						  END AS `성과역량평가점수`
					FROM hr_bi.TABLE5
					WHERE t_2 IN (2020,2019,2018)	-- 대상 년도
					/*----------------------------------------------------------*/
					) `성과역량`
				GROUP BY `성과역량평가점수`, `성과평가Key`
				/*----------------------------------------------------------*/
				) `연평균평가`
			/*----------------------------------------------------------*/
			) `평가3년평균tmp`
		GROUP BY `사원 번호`
		/*----------------------------------------------------------*/
		) `평가3년평균tmp1`
	),
/*========================================================================
								다면상중하
========================================================================*/
ZHHRT6400 AS (
	SELECT 
		  `사원 번호`
		, `LSV담당조직등급`
		, `LSV3년평균`
		, CASE WHEN `LSV담당조직등급` = 'S'
			   THEN CASE WHEN `LSV3년평균` >= 4.405 THEN '상'
						 WHEN `LSV3년평균` < 3.845 THEN '하'
						 ELSE '중'
						 END 
			   WHEN `LSV담당조직등급` = 'T'
			   THEN CASE WHEN `LSV3년평균` >= 4.385 THEN '상'
						 WHEN `LSV3년평균` < 3.635 THEN '하'
						 ELSE '중'
						 END
			   END AS `LSV3년상중하`
	FROM (
		SELECT
			  `다면대상`.`사원 번호`
			, `다면대상`.`LSV담당조직등급`
			, `개인별3년평균`.`LSV3년평균`
		FROM (
			/*------------------------ 다면대상 --------------------------*/
			SELECT 
				  t_2 AS `사원 번호`
				, CASE WHEN t_48 IN ('부사장','본부','사업부','실') THEN 'S' ELSE 'T' END AS `LSV담당조직등급`		-- `담당조직등급`
			FROM hr_bi.TABLE6
			WHERE 1=1
				AND t_49 <> '제외'		-- 직군
				AND LENGTH(t_49) > 0	-- 직군
				AND t_25 <> 'Z3'		-- 직위코드
				AND t_6 = '재직'			-- 재직/퇴직
				AND t_48 IN ('부사장','본부','사업부','실','팀','부') -- 담당조직등급
			/*----------------------------------------------------------*/
			) `다면대상`
		LEFT JOIN (
			/*---------------------- 개인별3년평균 ------------------------*/
			SELECT
				  `사원 번호`
				, AVG(`연도별평균`) AS `LSV3년평균`
			FROM (
				/*---------------------- 다면연도별평균 ------------------------*/
				SELECT
					  `%다면평균Key`
					, `연도별평균`
					, SUBSTR(`%다면평균Key`,9,8) AS `사원 번호`
				FROM (
					SELECT
						  `%다면평균Key`
						, AVG("평균 점수") AS `연도별평균`
					FROM (
						/*----------------------- 다면6400 --------------------------*/
						SELECT 
							  CONCAT(t_2,'|',t_3,'|',t_7,'|',t_6) AS `%다면Key`		-- "대상 년도"&'|'&회차&'|'&"평가자 사번"&'|'&"피평가자 사번"
							, CONCAT(t_2,'|',t_3,'|',t_6) AS `%다면평균Key`			-- "대상 년도"&'|'&회차&'|'&"피평가자 사번"
							, CONCAT(t_2,'|',t_3,'|',t_10) AS `%다면보직별Key`		-- "대상 년도"&'|'&회차&'|'&보직구분
							, t_2 AS `평가년도`				-- `대상 년도`
							, t_14 AS `다면종합_직급구분`		-- `직급 구분`
							, t_6 AS `사원 번호`				-- `피평가자 사번`
							, t_24 AS `다면피평가자소속조직명`		-- `피평가자 소속명`
							, t_9 AS `평가유형명`
							, t_11 AS `보직구분명`
							, CASE WHEN t_11 IN ('본부장','사업부장','실장') THEN 'S'
								   WHEN t_11 ='팀장'  THEN 'T'
							  END AS `보직구분명_수정`
							, CASE WHEN t_2 <= '2018' THEN t_42/7*5 ELSE t_42 END AS `평균 점수`
							, t_18 AS `피평가자 성명`
							, t_20 AS `피평가자 보직명`
						FROM hr_bi.TABLE7
						WHERE 1=1
							AND t_45 = '아니오'			-- 통계항목 포함여부명
							AND t_9 = '부하평가' 			-- 평가유형명
							AND t_2 IN (2021,2020,2019)	-- 대상 년도
							AND DATE(t_43) < '20211031'		-- 평가완료일		date(평가완료일) < 44500
						/*----------------------------------------------------------*/
						) T
					GROUP BY `%다면평균Key`
					) TT
				/*----------------------------------------------------------*/
				) `다면연도별평균`
			GROUP BY `사원 번호`
			) `개인별3년평균`
		ON `다면대상`.`사원 번호` = `개인별3년평균`.`사원 번호`
		) T
	)
SELECT 
	  *
	, CONCAT(`성과평가3개년상중하`,`LSV3년상중하_수정`) AS `평균성과및LSV_수정`
FROM (
	SELECT 
		  HR.*
		, Z6050.`성과평가3개년평균`
		, Z6050.`성과평가3개년상중하`
		, Z6400.`LSV담당조직등급`
		, Z6400.`LSV3년평균`
		, Z6400.`LSV3년상중하`
		, Z6050E.`임원성과평가3개년평균`
		, Z6050CR.`책임성과평가3개년평균`
		, CASE WHEN Z6400.`LSV3년상중하` IS NULL THEN '중' ELSE Z6400.`LSV3년상중하` END AS `LSV3년상중하_수정`
		, CASE WHEN Z6050.`성과평가3개년상중하` IS NULL THEN '중'ELSE Z6050.`성과평가3개년상중하` END AS `성과평가3년상중하_수정`
	FROM HR_MASTER HR 
	LEFT JOIN ZHHRT6050 Z6050		-- 전직급평가3개년평균
	ON HR.`사원 번호` = Z6050.`사원 번호`
	LEFT JOIN ZHHRT6400 Z6400		-- 다면상중하
	ON HR.`사원 번호` = Z6400.`사원 번호`
	LEFT JOIN ZHHRT6050_E Z6050E		-- 임원평가3년평균
	ON HR.`사원 번호` = Z6050E.`사원 번호`
	LEFT JOIN ZHHRT6050_CR Z6050CR		-- 직원평가3년평균
	ON HR.`사원 번호` = Z6050CR.`사원 번호`
	) T