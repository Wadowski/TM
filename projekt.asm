/;
Projekt numer 9 
Termometr 1-Wire – odczyt temperatury z 1 lub 2 czujników i wyświetlanie jej na LCD / UART. Wersja zaawansowana – rejestrowanie adresu czujnika który jest podpięty (na raz podpięty jest tylko jeden czujnik – NIE chodzi tu o wyszukiwanie urządzeń drzewem).

Dokumentacja czujnika: https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf
Wersja czujnika: TO-92

Autorzy: Dominik Wadowski, Grzegorz Podsiadło

;/
.PORT  lcd_value_p, 0x30
.PORT  lcd_control_p,  0x31
.PORT gpio_E, 0x24
.PORT gpio_E_dir, 0x2C ;; 1 - out, 0 - in       bit 0 - port 0

.REG S5, presence
.REG S8, lcd_val_reg
.REG S9, lcd_ctrl_reg_up
.REG SA, lcd_ctrl_reg_down
.REG SB, lcd_data_reg_up
.REG SC, lcd_data_reg_down
 
.DSEG ; RAM 
str: .db ".:" 


;; Przygladnac sie timerom na przerwaniach (ma ulatwic)

.CSEG
main:
	
	CALL lcd_init ;; Inicjalizacja lcd i wypisanie TEMP
 	;; TODO: Wracanie kursora do lewego górnego rogu przed pisaniem 
	petla:
		reset:
			CALL reset_pulse
			TEST presence, 1
			JUMP NZ, reset
	
	; Test czy widzi i wypisze na lcd T		
		LOAD lcd_val_reg,   'T'
		OUT lcd_val_reg, lcd_value_p
		OUT lcd_data_reg_up, lcd_control_p
		LOAD S0, S0
		LOAD S0, S0
		OUT lcd_data_reg_down, lcd_control_p
		CALL opoznij_1s

		JUMP petla


;; TODO: Poprawic te opóźnienia by byly mniej na oko
;;  Funkcje pozwalajace na generowanie opoznien 
.CONST  opoznij_1u_const, 23
opoznij_1u:
	LOAD s0, opoznij_1u_const
czekaj_1u:
	SUB  s0, 1
	JUMP NZ, czekaj_1u
	LOAD s0, s0        
	LOAD s0, s0
	RET

czekaj_2u:
	CALL opoznij_1u
	CALL opoznij_1u
	RET

czekaj_5u:
	CALL opoznij_1u
	CALL opoznij_1u
	CALL opoznij_1u
	CALL opoznij_1u
	CALL opoznij_1u
	RET

czekaj_15u:
	CALL czekaj_5u
	CALL czekaj_5u
	CALL czekaj_5u
	RET

czekaj_30u:
	CALL czekaj_15u
	CALL czekaj_15u
	RET

czekaj_80u:
	CALL czekaj_30u
	CALL czekaj_30u
	CALL czekaj_15u
	CALL czekaj_5u
	RET

czekaj_480u:
	CALL czekaj_80u
	CALL czekaj_80u
	CALL czekaj_80u
	CALL czekaj_80u
	CALL czekaj_80u
	CALL czekaj_80u
	RET

czekaj_500u:
	CALL czekaj_480u
	CALL czekaj_15u
	
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

set_presence_0:
	LOAD presence, 0
	RET

set_presence_1:
	LOAD presence, 1
	RET

;; 1 - out, 0 - in       bit 0 - port 0
reset_pulse:
	LOAD S2, 1
	LOAD S3, 0
	LOAD presence, 1
	OUT  S2, gpio_E_dir ;; ustawiamy port na out

	OUT S3, gpio_E ;; wysylamy 0
	CALL czekaj_480u ;; odczekujemy 480us
	OUT S2, gpio_E

	OUT S3, gpio_E_dir ;; ustawiamy na in
	CALL czekaj_30u ;; czekamy 30 us
	CALL czekaj_30u ;; czekamy 30 us
	IN S4, gpio_E
	TEST S4, 1
	CALL NZ, set_presence_0
	CALL czekaj_80u ;; moze byc za duzo
	CALL czekaj_80u ;; moze byc za duzo
	CALL czekaj_480u ;; odczekujemy 480us
	;IN S4, gpio_E
	;TEST S4, 1
	;CALL NZ, set_presence_1

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
 
