PROCEDURE str_Uslug1
DIMENSION a_name_usl(10),	a_count_uslug(10) 
CLEAR 
STORE '' TO a_name_usl
STORE '0' TO a_count_uslug
c_USLUGA ='Вклады 4 Кредиты 5 Дебетовые карты 19 Автокредиты 6 Ипотека 7Кредиты для бизнеса 16 Филиалы 4'
        	DO str_Uslug WITH c_USLUGA 
        	
        	i_usl=1
        	str_repl='REPLACE '
        	DO WHILE LEN(a_name_usl(i_usl)) <> 0
*!*	STORE '' TO a_name_usl
*!*	STORE 0 TO a_count_uslug
			* формируем строку REPLACE для услуг
			SELECT spr_uslugi
			LOCATE FOR name_uslug = a_name_usl(i_usl)
        	id_Uslug = spr_uslugi.id
        	str_repl = str_repl + 'u'+ ALLTRIM(STR(id_Uslug)) + ' WITH ' + a_count_uslug(i_usl)+ ' , '
        	i_usl = i_usl + 1
        	ENDDO 
?str_repl 
	str_repl =  SUBSTR(ALLTRIM(str_repl),1,LEN(ALLTRIM(str_repl))-1)
?str_repl 	
ENDPROC 

PROCEDURE str_Uslug
	PARAMETERS c_USLUGA 
EXTERNAL ARRAY a_name_usl, a_count_uslug	&& массив с колличеством определённой услуги

*!*	DIMENSION a_name_usl(10),	a_count_uslug(10)
*!*	STORE '' TO a_name_usl
*!*	STORE 0 TO a_count_uslug
*!*	c_USLUGA ='Вклады 4 Кредиты 5 Дебетовые карты 19 Автокредиты 6 Ипотека 7Кредиты для бизнеса 16 Филиалы 4'

  
i_usl=1
stroka_uslug=CHRTRAN(c_USLUGA  ,'1234567890','__________')
stroka_uslug=STRTRAN(stroka_uslug,CHR(160),'')
stroka_uslug=STRTRAN(stroka_uslug,'__','_')
stroka_uslug=STRTRAN(stroka_uslug,'__','_')

*CLEAR

*!*	?c_USLUGA 
*!*	?stroka_uslug
*!*	?ALEN(a_name_usl)
DO WHILE  i_usl < ALEN(a_name_usl)		&& формируем массив наименования услуг
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
    IF NOT FOUND() then
    	APPEND BLANK
    	REPLACE name_uslug WITH  ALLTRIM((a_name_usl(i_usl)))
    	*INSERT INTO spr_uslugi (name_uslug) VALUES ALLTRIM((a_name_usl(i_usl)))
    endif
    i_usl = i_usl + 1
ENDDO 
str_m_d=''
i_usl=1
DO WHILE  i_usl < ALEN(a_name_usl)		&& формируем массив колличества соответствующих услуг услуг
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