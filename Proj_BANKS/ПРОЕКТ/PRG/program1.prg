PROCEDURE program1
DIMENSION a_usl(20)	
CLEAR

c_USLUGA  ='Вклады 9 Кредиты 2 Кредитные карты 2 Дебетовые карты 2 Автокредиты 6Депозиты для юридических лиц 6 Филиалы 17'
?c_USLUGA  
 i_usl=1
        stroka_uslug=CHRTRAN(c_USLUGA  ,'1234567890','__________')
        DO WHILE  i_usl < ALEN(a_usl)
        	DO CASE 
        		CASE i_usl = 1
                a_usl(i_usl) = ALLTRIM(SUBSTR(stroka_uslug, 1, AT('_',  stroka_uslug,  i_usl)- 1 ))
                *CASE 
                OTHERWISE 
                a_usl(i_usl) = ALLTRIM(SUBSTR(stroka_uslug, AT('_',  stroka_uslug,  i_usl-1)+1, AT('_',  stroka_uslug,  i_usl) -AT('_',  stroka_uslug,  i_usl-1)-1))
                IF LEN(a_usl(i_usl)) =0
                	EXIT
                endif
			ENDCASE 
        ?i_usl, a_usl(i_usl)
        SELECT spr_uslugi
        LOCATE FOR name_uslug = a_usl(i_usl)
        IF NOT FOUND() then
        	? 'нет'
        	INSERT INTO spr_uslugi (name_uslug) VALUES (a_usl(i_usl))
        	ELSE
        	? 'YY'
        endif
        *IF a_usl(i_usl)='_'
        i_usl = i_usl + 1
        ENDDO 

return