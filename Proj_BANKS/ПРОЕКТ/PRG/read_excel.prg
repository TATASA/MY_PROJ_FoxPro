PROCEDURE read_excel 
on error do ErrorHandler with Error( ), Message( ), Message(1), Lineno( ), Program( ), Sys(16)
***  03/05/2017
*****************
* Процедура с помощью которой импортировала информацию из excel 
SET ENGINEBEHAVIOR 70 
SET DELETED ON
GlPath=SYS(5)+SYS(2003)       
SET DEFAULT TO &GlPath
SET PATH TO ;&Glpath;FORM;PRG;DATA

IF ! USED("spr_uslugi")
	USE spr_uslugi IN 0	
	SELECT spr_uslugi
ENDIF

IF ! USED("spr_city")
	USE spr_city IN 0	
	SELECT spr_city
ENDIF

*************
*!*	DIMENSION a_usl(20)		&& - предполагаю, что услуг не будет больше 20
DIMENSION a_name_usl(15),	a_count_uslug(15)	  		&& - предполагаю, что услуг не будет больше 15

im_file_new=GETFILE('XLS','Имя файла','Ввод',1,'Ищем файл *.xls')

IF EMPTY(im_file_new) then
	WAIT WINDOW 'Файл не выбран!' + CHR(10)+CHR(13)+'Работа программы прервана' AT 10, 10 TIMEOUT 3
	RETURN
ENDIF
* создадим курсор
CREATE CURSOR cur1 ;
       ( NAIM_B   C(50),;
        TELEF_B   C(20),;
        CITY   c(30),;
        NUM_LIC   N(10),;
        RATING    I(4), ;
        u1 N(4), u2 N(4), u3 N(4), u4 N(4), u5 N(4), u6 N(4), u7 N(4), u8 N(4), u9 N(4), u10 N(4), ;
        u11 N(4), u12 N(4), u13 N(4), u14 N(4), u15 N(4)  )
 
ole1=OBJXLS(im_file_new)
IF TYPE('ole1')#'O' OR ISNULL(ole1)
	RETURN .F.
ENDIF
WAIT WINDOW "Ждите! Идет подгрузка строк  из Excel (NEW)  " AT 20, 20 NOWAIT TIMEOUT 3

filnam_r=STRIPPATH(im_file_new)  
ole1.Application.Windows(filnam_r).Activate
oSheet=ole1.ActiveSheet	&& Работать будем с этой страницей
i_start=2		&& обрабртку ведём с 2 строки
i=i_start		
With oSheet
	DO WHILE .T.
		IF ISNULL(.Cells(i,1).Value)  && достигли конца листа
			EXIT
		ENDIF
        
        m.NAIM_B   =ALLTRIM(.Cells(i,1).Value)
        m.TELEF_B  =IIF(ISNULL(.Cells(i,2).Value),' ', ALLTRIM(.Cells(i,2).Value))
        c_CITY  =ALLTRIM(.Cells(i,3).Value)
        m.NUM_LIC  =IIF(ISNULL(.Cells(i,4).Value),0, VAL(ALLTRIM(.Cells(i,4).Value)))
        
        m.RATING   =IIF(isnull(.Cells(i,6).Value),0,( INT(.Cells(i,6).Value)))
        
        * формирую табл. услуги 
        IF VARTYPE(.Cells(i,5).Value)='C' then
        	c_USLUGA   = ALLTRIM(.Cells(i,5).Value)
        	*?c_USLUGA   
        	DO str_Uslug WITH c_USLUGA   
        	i_usl=1
        	str_repl='REPLACE '
        	DO WHILE LEN(a_name_usl(i_usl)) <> 0
			* формируем строку REPLACE для услуг
				SELECT spr_uslugi
				LOCATE FOR name_uslug = a_name_usl(i_usl)
	        	id_Uslug = spr_uslugi.id
	        	str_repl = str_repl + 'u'+ ALLTRIM(STR(id_Uslug)) + ' WITH ' + ALLTRIM(a_count_uslug(i_usl))+ ', '
	        	i_usl = i_usl + 1
        	ENDDO 
        	str_repl =  SUBSTR(ALLTRIM(str_repl),1,LEN(ALLTRIM(str_repl))-1) + ' IN Cur1'		&& убрали  ','
        	        	
        	ELSE
			str_repl = ''
        ENDIF
        * конец формир. табл. услуги 
        * 
        
        * формирую табл. города 
        SELECT spr_city
        
        LOCATE FOR city = c_CITY  
        IF NOT FOUND() then
        	INSERT INTO spr_city (city ) VALUES (c_CITY  )
        ENDIF
         *m.ID_CITY = spr_city.id
         m.CITY = spr_city.CITY 
         
         * конец формир. табл. города 
        
        SELECT cur1
        INSERT INTO  cur1 (NAIM_B, TELEF_B , CITY, NUM_LIC,  RATING, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, ;
        															u11, u12, u13, u14, u15) ;
        VALUES (m.NAIM_B, m.TELEF_B , m.CITY, m.NUM_LIC, m.RATING, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ;
        															0, 0, 0, 0, 0	)
         SELECT cur1
         *?str_repl 
         IF LEN(str_repl) > 20 then		&&  если  < 25 знаков строка не сформировалась! 
        	&str_repl 
         endif
        i=i+1
	ENDDO
ENDWITH

 WAIT WINDOW 'Прочитали из Excel (NEW) ' + STR(i-i_start) + ' строки.' AT 10,10
=ZakrXLS()

INSERT INTO  banks (NAIM_B, TELEF_B , CITY, NUM_LIC,  RATING, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, ;
        															u11, u12, u13, u14, u15) ;
SELECT DISTINCT Cur1.naim_b, Cur1.telef_b, Cur1.city, Cur1.num_lic, Cur1.rating,;
 Cur1.u1, Cur1.u2, Cur1.u3, Cur1.u4, Cur1.u5, Cur1.u6, Cur1.u7, Cur1.u8, Cur1.u9, Cur1.u10, ;
 Cur1.u11, Cur1.u12, Cur1.u13, Cur1.u14, Cur1.u15  FROM Cur1

SELECT cur1
USE

RETURN

********************************************************
***********END PROCEDURE read_excel **************************
*******************************************************************

FUNCTION OBJXLS
PARAMETERS x,y
LOCAL a,b
ole1=.NULL.
a=ON('ERROR')
ON ERROR ole1=.NULL.
ole1=GetObject(x)
IF TYPE('ole1')#'O' OR ISNULL(ole1)
	ole1=GetObject('Excel.Application')
	b=IIF(EMPTY(y),'Open Filename:=x','Create Filename:=x')
	ole1.Workbooks.&b
ENDIF
ON ERROR &a
RETURN ole1

FUNCTION ZakrXLS
PARAMETERS x
LOCAL a,b
With ole1.Application
	.DisplayAlerts=.F.          && Убрать запрос "Сохранить файл?" (перед выходом)
	IF TYPE('x')='L'
		a=ON('ERROR')
		b=.F.
		ON ERROR b=.T.
		.ActiveWorkBook.Save 			&& Сохраняем в файл
		IF b AND VAL(.Version)>=12
			ON ERROR &a
			.ActiveWorkBook.SaveAs(fil_excel+'x') 			&& Сохраняем в файл
			DELETE FILE (fil_excel)
		ENDIF
		ON ERROR &a
	ENDIF
	IF NOT EMPTY(x)
		.DisplayAlerts=.T.          && Убрать запрос "Сохранить файл?" (перед выходом)
		.visible=.T. 			&& Сделаем окно Excel видимым
	ELSE
		.ActiveWorkBook.Close 			&& Сохраняем в файл
		.Quit
	ENDIF
EndWith
RETURN 

FUNCTION strippath
PARAMETER m.x
RETURN SUBSTR(m.x,MAX(RAT('\',m.x),RAT(':',m.x))+1)

*********************************************
***************PROCEDURE str_Uslug******************************
*********************************************

PROCEDURE str_Uslug
	PARAMETERS c_USLUGA 
EXTERNAL ARRAY a_name_usl, a_count_uslug	&& массив с колличеством определённой услуги

*  удаляю невидимый код CHR(160) из строки c_USLUGA 
c_USLUGA =STRTRAN(c_USLUGA ,CHR(160),'')

*DIMENSION a_name_usl(10),	a_count_uslug(10)
STORE '' TO a_name_usl
STORE 0 TO a_count_uslug
*c_USLUGA ='Вклады 4 Кредиты 5 Дебетовые карты 19 Автокредиты 6 Ипотека 7Кредиты для бизнеса 16 Филиалы 4'

i_usl=1
stroka_uslug=CHRTRAN(c_USLUGA  ,'1234567890','__________')
stroka_uslug=STRTRAN(stroka_uslug,CHR(160),'')
stroka_uslug=STRTRAN(stroka_uslug,'__','_')
stroka_uslug=STRTRAN(stroka_uslug,'__','_')		&& контрольный!

*CLEAR
*?c_USLUGA 
*?stroka_uslug
*?ALEN(a_name_usl)
DO WHILE  i_usl <= ALEN(a_name_usl)		&& формируем массив наименования услуг
	DO CASE 
		CASE i_usl = 1
        a_name_usl(i_usl) = ALLTRIM(SUBSTR(stroka_uslug, 1, AT('_',  stroka_uslug,  i_usl)- 1 ))
        OTHERWISE 
        a_name_usl(i_usl) = ALLTRIM(SUBSTR(stroka_uslug, AT('_',  stroka_uslug,  i_usl-1)+1, AT('_',  stroka_uslug,  i_usl) -AT('_',  stroka_uslug,  i_usl-1)-1))
        IF LEN(a_name_usl(i_usl)) =0
        	EXIT
        endif
	ENDCASE 
         a_name_usl(i_usl)=ALLTRIM(a_name_usl(i_usl))

    SELECT spr_uslugi
    LOCATE FOR name_uslug = ALLTRIM(a_name_usl(i_usl))
    IF NOT FOUND() then		&& если услуги ещё нет в справочнике добавим её
    	APPEND BLANK
    	REPLACE name_uslug WITH  ALLTRIM((a_name_usl(i_usl)))
    	*INSERT INTO spr_uslugi (name_uslug) VALUES ALLTRIM((a_name_usl(i_usl)))
    endif
    i_usl = i_usl + 1
ENDDO 
str_m_d=''
i_usl=1
DO WHILE  i_usl <= ALEN(a_name_usl)		&& формируем массив колличества соответствующих услуг услуг
	IF LEN(ALLTRIM(a_name_usl(i_usl+1))) = 0 then
		str_m_d=SUBSTR(c_USLUGA ,AT(a_name_usl(i_usl),c_USLUGA)+LEN(a_name_usl(i_usl)))
		*?a_name_usl(i_usl), str_m_d
		a_count_uslug(i_usl)=ALLTRIM(str_m_d)
		EXIT 
	ELSE
		str_m_d=SUBSTR(c_USLUGA , AT(a_name_usl(i_usl),c_USLUGA)+LEN(a_name_usl(i_usl)), AT(a_name_usl(i_usl+1),c_USLUGA)- (AT(a_name_usl(i_usl),c_USLUGA)+LEN(a_name_usl(i_usl))))
	ENDIF 
	*?a_name_usl(i_usl), 
	a_count_uslug(i_usl)=ALLTRIM(str_m_d)
	i_usl = i_usl + 1
ENDDO 
c_USLUGA   =''

ENDPROC 

*********************************************
***************PROCEDURE str_Uslug******************************
*********************************************
