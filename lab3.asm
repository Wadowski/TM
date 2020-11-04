.PORT  diody, 0x0
.PORT  przelaczniki, 0x10
.PORT  przyciski,  0x11
.PORT  lcd_value_p, 0x30
.PORT  lcd_control_p,  0x31
.PORT  uart_0_rtx_p, 0x60
.PORT  uart_0_status, 0x61
.PORT buttons_int_mask, 0x12
.PORT int_mask, 0xE1
.PORT int_status, 0xE0
.PORT uart0_int_mask, 0x62

.REG S7, diody_reg
.REG S8, lcd_val_reg
.REG S9, lcd_ctrl_reg_up
.REG SA, lcd_ctrl_reg_down
.REG SB, lcd_data_reg_up
.REG SC, lcd_data_reg_down
 
.DSEG ; RAM 
str: .db "Temp:" ;  Łańcuch znaków z tekstem powitalnym

.CSEG
main:
	EINT ; Uruchomienie przerwan
  LOAD diody_reg, 0 
  ; Uruchomienie przerwan dla przyciskow i uart0
	LOAD  S1, 0b101
	OUT S1, int_mask
	; Uruchomienie przerwania dla przycisku numer 1 oraz opcji dla zbocza
	LOAD  S1, 0b10000010 
	OUT S1, buttons_int_mask
	; Uruchomienie przerwan dla UART rx_not_empty
	LOAD S1, 0x10 
	OUT S1, uart0_int_mask

	LOAD S1, 1
	CALL lcd_init ;; Inicjalizacja lcd
 	;CALL petla
	petla2: ; Petla czekajaca na dane z UART i wypisujaca je na lcd
		LOAD SE, 0
		CALL wait_for_uart
		CALL wypisz_na_lcd
		JUMP petla2



;;   Funkcje pozwalajace na generowanie opoznien 
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

opoznij_25m:
	LOAD s3, 250
czekaj_25m:
	CALL opoznij_1m
	SUB s3, 1
	JUMP NZ, czekaj_1m
	RET

opoznij_1s:
	LOAD s4, 100
czekaj_1s:
	CALL opoznij_25m
	SUB s4, 1
	JUMP NZ, czekaj_1s
	RET
 
; Petla w ktorej sprawdzane sa przyciski  i odpowiednio zmienione wartosci -  druga wajcha - wtedy jest tryb ze jak wciska sie przycisk zero to sie dodaje wartosc, jak druga wajcha jest opuszczona
; to gdy pierwsza nie jest podniesiona  - dodaja sie szybko wartosci, a gdy jest podniesiona to sie przesuwaja w lewo
petla:
	CALL czekaj_1s
	IN S5, przelaczniki ; Wartosc przelacznikow
	IN S6, przyciski ; Wartosc przyciskow
       
	TEST S5, 2
	JUMP Z, not_using_button
	CALL NZ,  test_button
	JUMP change_end;
 
	not_using_button:
	TEST S5, 1
	CALL NZ, shift
	CALL Z, add_num
 
	change_end:
	OUT S1,         diody ; Wyswietlanie wartosci  na diodach
	JUMP petla ; Wykonuj wszystko w petli
   RET

; Zmiana wartosci wedlug przesuniecia o jedno
.CSEG 0x1FF
shift:
	RL S1
	RET
 
; Zmiana wartosci wedlug dodania jednego
add_num:
	ADD S1, 1
	RET
 
; Dodaje liczby jezeli wcisnieto przycisk
test_button:
	TEST S6 , 1
	CALL NZ, add_num
	czekaj_do_puszczenia:
		IN S6, przyciski
		TEST S6, 1
		JUMP NZ, czekaj_do_puszczenia
		RET
 
/;
 Inicjalizuje wyswietlacz oraz wysyla poczatkowy napis 
lcd_control - linie kontrolne wyswietlacza
bity:
0 - lcd_e - impulsc wpisujacy
1 - lcd_rs - interpretacja danych 0 - komenda, 1 dane
2 - lcd_rw - kierunek transmisji - zawsze 0
Na lcd chcemy opoznienie 5ms najlepiej miedzy kazdymi instrukcjami minimum (patrz dokumentacja)
;/
 
lcd_init:
  LOAD lcd_val_reg, 0x38
  LOAD lcd_ctrl_reg_up, 0b001
  LOAD lcd_ctrl_reg_down, 0b000
  LOAD lcd_data_reg_up, 0b011
  LOAD lcd_data_reg_down, 0b010
 
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_ctrl_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_ctrl_reg_down, lcd_control_p
	CALL opoznij_1s
 
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_ctrl_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_ctrl_reg_down, lcd_control_p
	CALL opoznij_1s

 
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_ctrl_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_ctrl_reg_down, lcd_control_p
	CALL opoznij_1s

 
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_ctrl_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_ctrl_reg_down, lcd_control_p
	CALL opoznij_1s

  
	LOAD lcd_val_reg,  0x6
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_ctrl_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_ctrl_reg_down, lcd_control_p
	CALL opoznij_1s

 
	LOAD lcd_val_reg,  0xE
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_ctrl_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_ctrl_reg_down, lcd_control_p
	CALL opoznij_1s

 
	LOAD lcd_val_reg,  0x1
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_ctrl_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_ctrl_reg_down, lcd_control_p
	CALL opoznij_1s

 
	LOAD lcd_val_reg,  0xCC
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_ctrl_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_ctrl_reg_down, lcd_control_p
	CALL opoznij_1s

	
  ; Kod wypisujacy napis z RAMU
	LOAD SE, str
	wypisz_napis:
	FETCH  lcd_val_reg, SE
	COMP lcd_val_reg, 0
	JUMP Z, koniec_napisu

	OUT lcd_val_reg, lcd_value_p
	OUT lcd_data_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_data_reg_down, lcd_control_p
	CALL opoznij_1s

	ADD SE, 1
	JUMP wypisz_napis
	
	koniec_napisu:
	RET
 
;; Czeka az pojawi sie cos na buforze UART  dla odbierania danych
wait_for_uart:
	IN SE,  uart_0_status
	TEST SE, 16
	JUMP Z, wait_for_uart
	RET
 

;; Wypisuje na lcd znaki wyslane do kontrolera przez UART
wypisz_na_lcd:
	IN SE, uart_0_rtx_p
	LOAD lcd_val_reg,   SE
	OUT lcd_val_reg, lcd_value_p
	OUT lcd_data_reg_up, lcd_control_p
	LOAD S0, S0
	LOAD S0, S0
	OUT lcd_data_reg_down, lcd_control_p
	CALL czekaj_25m
	RET



/;
 OBSŁUGA PRZERWAŃ
;/

; Po otrzymaniu przerwania dodaje jeden do rejestru z sumą na diodach aktualizuje je
diody_int:
	ADD  diody_reg, 1
	OUT diody_reg, diody
	RET

 ; Po otrzymaniu litery na UART0 odsyła na UART0 tą sąmą literę przesuniętą w ASCII o 1
uart_int:
	IN SE, uart_0_rtx_p
	ADD SE, 1 
	OUT SE, uart_0_rtx_p
	RET

obsluga_przerwania: 
	IN S1, int_status	
	; Sprawdzamy status żeby wiedzieć co dało przerwanie 
	TEST S1, 1 
	CALL NZ, diody_int
	TEST S1, 1 << 2
	CALL Z, uart_int
 	; Trzeba wyczyscic status, bo wywoła się samo ponownie po obsłudze
	LOAD S1, 0 
	OUT S1,  int_status
	RETI  ; Wracamy i włączamy przerwania

 ; Skok do obsługi przerwania 
.CSEG 0x3FF
	JUMP obsluga_przerwania
