
CREATE  TABLE klasy ( 
	id_klasy             integer  NOT NULL ,
	nazwa                varchar(20)  NOT NULL ,
	CONSTRAINT pk_klasa_paczki_id_klasy PRIMARY KEY ( id_klasy ),
	CONSTRAINT unq_klasa_paczki_nazwa UNIQUE ( nazwa ) 
 );

CREATE  TABLE klienci ( 
	id_klienta           integer  NOT NULL ,
	nazwa                varchar(20)  NOT NULL ,
	numer_telefonu       varchar(15)   ,
	email                varchar(30)   ,
	CONSTRAINT pk_klienci_id_klienta PRIMARY KEY ( id_klienta )
 );

ALTER TABLE klienci ADD CONSTRAINT cns_klienci CHECK ( email is not null or numer_telefonu is not null );

CREATE  TABLE paczkomaty ( 
	id_paczkomatu        integer  NOT NULL ,
	miasto               varchar(20)  NOT NULL ,
	ulica_nr             varchar(20)  NOT NULL ,
	CONSTRAINT pk_paczkomaty_id_paczkomatu PRIMARY KEY ( id_paczkomatu )
 );

CREATE INDEX idx_paczkomaty_miasto ON paczkomaty ( miasto );

CREATE  TABLE pracownicy ( 
	id_pracownika        integer  NOT NULL ,
	imie                 varchar(20)  NOT NULL ,
	nazwisko             varchar(20)  NOT NULL ,
	CONSTRAINT pk_pracownicy_id_pracownika PRIMARY KEY ( id_pracownika )
 );

CREATE  TABLE przewozy ( 
	id_przewozu          integer  NOT NULL ,
	id_pracownika        integer  NOT NULL ,
	data_rozpoczecia     timestamp DEFAULT current_timestamp NOT NULL ,
	data_zakonczenia     timestamp   ,
	CONSTRAINT pk_przewozy_id_przewozu PRIMARY KEY ( id_przewozu )
 );

ALTER TABLE przewozy ADD CONSTRAINT cns_przewozy CHECK ( data_rozpoczecia <= data_zakonczenia or data_zakonczenia is null );

CREATE INDEX indeks_pracownika ON przewozy ( id_pracownika );

CREATE  TABLE rabaty_stale_klienci ( 
	id_klienta           integer  NOT NULL ,
	rabat                numeric(5,2)  NOT NULL ,
	CONSTRAINT pk_rabaty_stale_klienci_id_klienta PRIMARY KEY ( id_klienta )
 );

ALTER TABLE rabaty_stale_klienci ADD CONSTRAINT cns_rabaty_stale_klienci CHECK ( 0 <= rabat and rabat <=100 );

CREATE  TABLE stany ( 
	id_stanu             integer  NOT NULL ,
	opis                 varchar(50)  NOT NULL ,
	CONSTRAINT pk_stany_id_stanu PRIMARY KEY ( id_stanu )
 );

CREATE  TABLE typy ( 
	id_typu              integer  NOT NULL ,
	wymiar_x             numeric(5,2)  NOT NULL ,
	wymiar_y             numeric(5,2)  NOT NULL ,
	wymiar_z             numeric(5,2)  NOT NULL ,
	CONSTRAINT pk_typy_paczek_id_typu PRIMARY KEY ( id_typu ),
	CONSTRAINT unq_typy_paczek_wymiar UNIQUE ( wymiar_x, wymiar_y, wymiar_z ) 
 );

CREATE  TABLE cena_klasa_typ ( 
	id_klasy             integer  NOT NULL ,
	id_typu              integer  NOT NULL ,
	cena                 numeric(6,2)  NOT NULL ,
	CONSTRAINT pk_cena_klasa_typ PRIMARY KEY ( id_klasy, id_typu )
 );

CREATE  TABLE paczki ( 
	id_paczki            integer  NOT NULL ,
	id_typu              integer  NOT NULL ,
	id_klasy             integer  NOT NULL ,
	id_paczkomatu_nadania integer   ,
	id_paczkomatu_odbioru integer  NOT NULL ,
	id_nadawcy           integer  NOT NULL ,
	id_odbiorcy          integer  NOT NULL ,
	opis                 varchar(150)   ,
	CONSTRAINT pk_paczki_id_paczki PRIMARY KEY ( id_paczki )
 );

CREATE INDEX indeks_odbiorcy ON paczki ( id_odbiorcy );

CREATE INDEX indeks_nadawcy ON paczki ( id_nadawcy );

CREATE  TABLE paczkomaty_paczki ( 
	id_paczkomatu        integer  NOT NULL ,
	id_paczki            integer  NOT NULL ,
	CONSTRAINT pk_paczkomaty_paczki PRIMARY KEY ( id_paczkomatu, id_paczki )
 );

CREATE  TABLE pojemnosc_paczkomatu ( 
	id_paczkomatu        integer  NOT NULL ,
	id_typu              integer  NOT NULL ,
	liczba_miejsc        integer  NOT NULL ,
	CONSTRAINT pk_pojemnosc_paczkomatu PRIMARY KEY ( id_paczkomatu, id_typu )
 );

CREATE  TABLE przewozy_paczki ( 
	id_przewozu          integer  NOT NULL ,
	id_paczki            integer  NOT NULL ,
	CONSTRAINT pk_przewozy_paczki PRIMARY KEY ( id_przewozu, id_paczki )
 );

CREATE  TABLE hasze ( 
	id_paczki            integer  NOT NULL ,
	hasz                 varchar(20)  NOT NULL ,
	CONSTRAINT pk_hasze_id_paczki PRIMARY KEY ( id_paczki )
 );

CREATE  TABLE historia_paczek ( 
	id_paczki            integer  NOT NULL ,
	id_stanu             integer  NOT NULL ,
	data_zmiany          timestamp DEFAULT current_timestamp NOT NULL ,
	CONSTRAINT pk_historia_paczek PRIMARY KEY ( id_paczki, data_zmiany )
 );

CREATE INDEX indeks_paczki ON historia_paczek ( id_paczki );

ALTER TABLE cena_klasa_typ ADD CONSTRAINT fk_cena_klasa_typ_klasa_paczki FOREIGN KEY ( id_klasy ) REFERENCES klasy( id_klasy );

ALTER TABLE cena_klasa_typ ADD CONSTRAINT fk_cena_klasa_typ_typy_paczek FOREIGN KEY ( id_typu ) REFERENCES typy( id_typu );

ALTER TABLE hasze ADD CONSTRAINT fk_hasze_paczki FOREIGN KEY ( id_paczki ) REFERENCES paczki( id_paczki );

ALTER TABLE historia_paczek ADD CONSTRAINT fk_historia_paczek_paczki FOREIGN KEY ( id_paczki ) REFERENCES paczki( id_paczki );

ALTER TABLE historia_paczek ADD CONSTRAINT fk_historia_paczek_stany FOREIGN KEY ( id_stanu ) REFERENCES stany( id_stanu );

ALTER TABLE paczki ADD CONSTRAINT fk_paczki_typy_paczek FOREIGN KEY ( id_typu ) REFERENCES typy( id_typu );

ALTER TABLE paczki ADD CONSTRAINT fk_paczki_klienci FOREIGN KEY ( id_nadawcy ) REFERENCES klienci( id_klienta );

ALTER TABLE paczki ADD CONSTRAINT fk_paczki_klienci_0 FOREIGN KEY ( id_odbiorcy ) REFERENCES klienci( id_klienta );

ALTER TABLE paczki ADD CONSTRAINT fk_paczki_paczkomaty FOREIGN KEY ( id_paczkomatu_nadania ) REFERENCES paczkomaty( id_paczkomatu );

ALTER TABLE paczki ADD CONSTRAINT fk_paczki_paczkomaty_0 FOREIGN KEY ( id_paczkomatu_odbioru ) REFERENCES paczkomaty( id_paczkomatu );

ALTER TABLE paczki ADD CONSTRAINT fk_paczki_klasa_paczki FOREIGN KEY ( id_klasy ) REFERENCES klasy( id_klasy );

ALTER TABLE paczkomaty_paczki ADD CONSTRAINT fk_paczkomaty_paczki_paczkomaty FOREIGN KEY ( id_paczkomatu ) REFERENCES paczkomaty( id_paczkomatu );

ALTER TABLE paczkomaty_paczki ADD CONSTRAINT fk_paczkomaty_paczki_paczki FOREIGN KEY ( id_paczki ) REFERENCES paczki( id_paczki );

ALTER TABLE pojemnosc_paczkomatu ADD CONSTRAINT fk_pojemnosc_paczkomatu_typy_paczek FOREIGN KEY ( id_typu ) REFERENCES typy( id_typu );

ALTER TABLE pojemnosc_paczkomatu ADD CONSTRAINT fk_pojemnosc_paczkomatu_paczkomaty FOREIGN KEY ( id_paczkomatu ) REFERENCES paczkomaty( id_paczkomatu );

ALTER TABLE przewozy ADD CONSTRAINT fk_pracownik FOREIGN KEY ( id_pracownika ) REFERENCES pracownicy( id_pracownika );

ALTER TABLE przewozy_paczki ADD CONSTRAINT fk_przewoz FOREIGN KEY ( id_przewozu ) REFERENCES przewozy( id_przewozu );

ALTER TABLE przewozy_paczki ADD CONSTRAINT fk_paczka FOREIGN KEY ( id_paczki ) REFERENCES paczki( id_paczki );

ALTER TABLE rabaty_stale_klienci ADD CONSTRAINT fk_rabaty_stale_klienci_klienci FOREIGN KEY ( id_klienta ) REFERENCES klienci( id_klienta );

insert into klasy values (1,'zwykla'), (2,'premium');

insert into typy values (1,10,20,20), (2,20,30,30);

insert into cena_klasa_typ values (1,1,8), (2,1,10), (1,2,12), (2,2,15);

insert into pracownicy values (1,'Jan','Kowalski'), (2,'Adam','Nowak'), (3, 'Tomasz', 'Krakowski');

insert into klienci values (1,'Amazon','600500400','amazon@amazon.pl'), (2,'Jan Wojcik', '615789432', 'janwojcik@gmail.com'), (3, 'Joanna Nowicka', '557980043', null), 
(4, 'Zabawki dla dzieci', '543786100', 'zabawki@gmail.com'), (5, 'Anna Jarosz', null, 'jaroszanna@wp.pl');

insert into rabaty_stale_klienci values (1,20);

insert into stany values (1, 'oczekuje nadania'), (2, 'nadana'), (3, 'w doreczeniu'), (4, 'gotowa do odbioru'), (5, 'odebrana'), (6, 'w punkcie zbiorczym');

insert into paczkomaty values (1,'Krakow', 'Lojasiewicza 6'), (2,'Krakow', 'Lubicz 43'), (3,'Tarnow','Krakowska 149');

insert into pojemnosc_paczkomatu values (1,1,20), (1,2,15), (2,1,30), (2,2,20), (3,1,30), (3,2,20);

insert into paczki values (1,2,1,null,1,1,2,null), (2,1,1,null,2,1,3,'ksiazki'), (3,2,2,1,3,1,5,'pilne'), (4,1,2,null,3,4,5,'zabawki'), (5,1,1,3,2,5,3,null), (6,1,2,null,1,1,2,null);

insert into hasze values (1,872097098), (4,785610544);

insert into paczkomaty_paczki values (1,1), (1,3), (2, 4);

insert into historia_paczek values (1,2,timestamp '20-04-2021 10:23:54'), (1,3,timestamp '20-04-2021 20:23:54'), (1,4,timestamp '21-04-2021 10:53:54'),
(2,1,timestamp '22-04-2021 12:33:14'), (2,2,timestamp '22-04-2021 15:33:14'), (2,3,timestamp '23-04-2021 12:33:14'),
(3,1,timestamp '23-04-2021 11:37:17'), (3,2,timestamp '23-04-2021 15:39:17'),
(4,2,timestamp '20-04-2021 10:23:54'), (4,3,timestamp '20-04-2021 20:23:54'), (4,3,timestamp '20-04-2021 23:23:54'), (4,4,timestamp '21-04-2021 10:53:54'),
(5,2,timestamp '10-04-2021 10:23:54'), (5,3,timestamp '10-04-2021 19:40:24'), (5,4,timestamp '11-04-2021 10:23:54'), (5,6,timestamp '14-04-2021 12:23:54'), (5,5,timestamp '15-04-2021 12:23:54'),
(6,1,timestamp '10-04-2021 09:20:51'), (6,2,timestamp '10-04-2021 10:23:54'), (6,3,timestamp '10-04-2021 19:40:24'), (6,4,timestamp '11-04-2021 10:23:54'), (6,5,timestamp '12-04-2021 12:23:54');

insert into przewozy values (1,1, timestamp '20-04-2021 10:23:54', timestamp '20-04-2021 15:23:54'), (2,2, timestamp '10-04-2021 11:23:54', null), 
(3,3, timestamp '10-04-2021 21:17:09', '10-04-2021 23:17:09'), (4,1, timestamp '11-04-2021 11:23:54', timestamp '11-04-2021 13:23:54'), 
(5,1, timestamp '14-04-2021 10:23:54', timestamp '14-04-2021 15:23:54'), (6,3, timestamp '20-04-2021 20:28:54', timestamp '21-04-2021 04:23:54'), 
(7,1, timestamp '23-04-2021 07:48:32', timestamp '23-04-2021 15:23:54');

insert into przewozy_paczki values (1,1), (1,4), (2,5), (3,5), (3,6), (4,6), (5,5), (6,4), (7,2);

