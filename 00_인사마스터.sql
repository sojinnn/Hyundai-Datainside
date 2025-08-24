/*------------------------------------ 0_인사마스터 -----------------------------------
 * 기준 테이블
-----------------------------------------------------------------------------------*/
SELECT 
--	  HR.Key AS `Key`
	  HR.t_1 AS `클라이언트`
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
	, HR.t_48 AS `담당조직등급`
	, HR.t_49 AS `직군`
	, HR.t_50 AS `실거주지.우편번호`
	, HR.t_51 AS `실거주지.지역명`
	, HR.t_52 AS `실거주지.시`
	, HR.t_53 AS `실거주지.지역`
	, HR.t_54 AS `실거주지.주소`
	, HR.t_55 AS `회사입사일`
	, HR.t_56 AS `장기근속기준일`
	, HR.t_57 AS `현직승진일`
	, HR.t_58 AS `경력인정일`
	, HR.t_59 AS `승진기준일`
	, HR.t_60 AS `승급기준일`
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
-- 	, HR.t_75 AS `희망부문`
	, HR.t_76 AS `구.사번`
-- 	, HR.t_77 AS `회사구분`
	, HR.t_78 AS `채용시스템ID`
	, HR.t_79 AS `입사정보.퇴직내용`
	, HR.t_80 AS `공채기수`
	, HR.t_81 AS `암호화된비밀번호`
	, HR.t_82 AS `입사근거`
	, HR.t_83 AS `입사구분`
-- 	, HR.t_84 AS `희망분야`
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
	, HR.t_124 AS `사외경력.직종`
	, HR.t_125 AS `사외경력.대기업군코드`
	, HR.t_126 AS `사외경력.업종코드`
	, HR.t_127 AS `사외경력.회사코드`
	, HR.t_128 AS `사외경력.회사`
	, HR.t_129 AS `사외경력.회사명(대표)`
	, HR.t_130 AS `사외경력.업종`
	, HR.t_131 AS `사외경력.대기업군명`
	, HR.t_132 AS `사외경력.직종명`
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
	, HR.t_157 AS `연구직 비고`
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
	, HR.`그룹입사일(YYMMDD)`
	, HR.`계약종료예정일(YYMMDD)`
	, HR.`복귀예정일(YYMMDD)`
	, HR.`최초부임일(YYMMDD)`
	, CASE WHEN TRIM(t_99) = '' THEN NULL
		   ELSE
				CASE WHEN FLOOR(DATEDIFF(CURRENT_DATE,HR.`최초부임일(YYMMDD)`) / 365.25) = 0
					 THEN '1년 미만' ELSE '1년 이상' END 
		   END AS `@주재원부임기간`
	, HR.`퇴직기본.종료일(YYMMDD)`
	, HR.`퇴직일(YYMMDD)`
	, YEAR(HR.`퇴직일(YYMMDD)`) AS `퇴직년도`
	, MONTH(HR.`퇴직일(YYMMDD)`) AS `퇴직월`
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
	, B.t_10 AS `보직임명일자`
	, B.t_11 AS `수습여부`
-- 	, B.t_12 AS `보직유무`
-- 	, B.t_13 AS `보직유무명`
	, B.t_14 AS `보직등급`
	, B.t_15 AS `조직등급명칭`
-- 	, B.t_16 AS `직책`
-- 	, B.t_17 AS `직책명`
-- 	, B.t_18 AS `근속기준일`
	, B.t_19 AS `휴직중구분`
	, B.t_20 AS `정직중구분`
	, B.t_21 AS `파견중구분`
	, B.t_22 AS `상근비상근여부`
	, B.t_23 AS `근속년`
	, CAST(TRIM(B.t_23) AS INT) AS `근속년수`
	, B.t_24 AS `근속월`
	, B.t_25 AS `승진년차`
-- 	, B.t_26 AS `장기근속기준일`
	, B.t_27 AS `연구직 연차진행일`
	, B.t_28 AS `연구직 승급연차`
-- 	, B.t_29 AS `휴직사유`
-- 	, B.t_30 AS `휴직사유명칭`
	, B.t_31 AS `겸직여부`
	, B.t_32 AS `후 겸직부서(말단조직)`
-- 	, B.t_33 AS `당사입사일`
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
-- 	, B.t_44 AS `사원 그룹 이름`
-- 	, B.t_45 AS `채용지역`
-- 	, B.t_46 AS `채용지역명`
-- 	, B.t_47 AS `초임구분`
-- 	, B.t_48 AS `초임구분2`
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
		, DATE_FORMAT(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_154), '.', '-'), 'yyyy-M-d'))), 'yyyyMM') AS `YYYYMM`	-- 작업일자
	FROM hr_bi.pa0002_hr_master_yearly
	WHERE t_6 = '재직'	-- 재직/퇴직
	) HR
/*----------------------------------------------------------*/
LEFT JOIN (
/*--------------------------- B ----------------------------*/
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
		, DATE_FORMAT(TO_DATE(FROM_UNIXTIME(UNIX_TIMESTAMP(REPLACE(TRIM(t_73), '.', '-'), 'yyyy-M-d'))), 'yyyyMM') AS `YYYYMM`	-- 작업일자
	FROM hr_bi.zhhrt9359_hr_master_yearly
	) B
/*----------------------------------------------------------*/
ON  HR.`YYYYMM` = B.`YYYYMM` 	-- [HR]	Year(작업일자) & Num(Month(작업일자), '00') & '|' & 클라이언트 & '|' & "사원 번호" As %인사PKey
AND HR.t_1 		= B.t_1 		-- [B] 	Year(작업일자) & Num(Month(작업일자), '00') & '|' & 클라이언트 & '|' & "사원 번호" As %인사PKey
AND HR.t_2 		= B.t_3
