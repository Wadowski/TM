
/; MAIN
;/
main: 
	LOAD S1, 1
	CALL petla

/;  Kod czekajacy odpowiednia ilosc czasu
;/
.CONST  opoznij_1u_const, 23
opoznij_1u: 
	LOAD s0, opoznij_1u_const
czekaj_1u: 
	SUB  s0, 1
	JUMP NZ, czekaj_1u
	LOAD s0, s0        
	LOAD s0, s0
	RET
opoznij_1m: 
	LOAD s2, 250
czekaj_1m: 
	CALL opoznij_1u
	SUB  s2, 1
	JUMP NZ, czekaj_1m
	RET
opoznij_250m:
	LOAD s3, 250
czekaj_250m:
	CALL opoznij_1m
	SUB s3, 1
	JUMP NZ, czekaj_1m
	RET
opoznij_1s:
	LOAD s4, 10
czekaj_1s:
	CALL opoznij_250m
	SUB s4, 1
	JUMP NZ, czekaj_1s
	RET

; Petla w ktorej sprawdzane sa przyciski  i odpowiednio zmienione wartosci -  druga wajcha - wtedy jest tryb ze jak wciska sie przycisk zero to sie dodaje wartosc, jak druga wajcha jest opuszczona
; to gdy pierwsza nie jest podniesiona  - dodaja sie szybko wartosci, a gdy jest podniesiona to sie przesuwaja w lewo
petla:
	CALL czekaj_1s
	IN S5, 0x10 ; Wartosc przelacznikow
	IN S6, 0x11 ; Wartosc przyciskow
	
	TEST S5, 2
 	JUMP Z, not_using_button
	CALL NZ,  test_button
	JUMP change_end;

	 not_using_button:
	TEST S5, 1
	CALL NZ, shift
	CALL Z, add_num

	change_end:
	OUT S1, 	0 ; Wyswietlanie wartosci  na diodach
	JUMP petla ; Wykonuj wszystko w petli

; Zmiana wartosci wedlug przesuniecia o jedno
.CSEG 0x1FF
	shift:
		RL S1
		RET

; Zmiana wartosci wedlug dodania jednego
add_num:
		ADD S1, 1
		RET

test_button:
	TEST S6 , 1
	CALL NZ, add_num
	RET