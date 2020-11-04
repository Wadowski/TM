/;
Projekt numer 9 
Termometr 1-Wire – odczyt temperatury z 1 lub 2 czujników i wyświetlanie jej na LCD / UART. Wersja zaawansowana – rejestrowanie adresu czujnika który jest podpięty (na raz podpięty jest tylko jeden czujnik – NIE chodzi tu o wyszukiwanie urządzeń drzewem).

Dokumentacja czujnika: https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf
Wersja czujnika: TO-92

Autorzy: Dominik Wadowski, Grzegorz Podsiadło

;/
.PORT  lcd_value_p, 0x30
.PORT  lcd_control_p,  0x31

.REG S8, lcd_val_reg
.REG S9, lcd_ctrl_reg_up
.REG SA, lcd_ctrl_reg_down
.REG SB, lcd_data_reg_up
.REG SC, lcd_data_reg_down
 
.DSEG ; RAM 
str: .db "Temp:" 


;; Przygladnac sie timerom na przerwaniach (ma ulatwic)

.CSEG
main:
	
	CALL lcd_init ;; Inicjalizacja lcd i wypisanie TEMP
 	;; TODO: Wracanie kursora do lewego górnego rogu przed pisaniem 

	petla:
	LOAD S0, S0
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
 
