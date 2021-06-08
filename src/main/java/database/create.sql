
CREATE  TABLE klasy ( 
	id_klasy             integer  NOT NULL ,
	nazwa                varchar(20)  NOT NULL ,
	CONSTRAINT pk_klasa_paczki_id_klasy PRIMARY KEY ( id_klasy ),
	CONSTRAINT unq_klasa_paczki_nazwa UNIQUE ( nazwa ) 
 );

create sequence klienci_seq start 1 increment by 1;

CREATE  TABLE klienci (
	id_klienta           integer DEFAULT nextval('klienci_seq') NOT NULL ,
	nazwa                varchar(20)  NOT NULL ,
	numer_telefonu       varchar(15)   ,
	email                varchar(30)   ,
	CONSTRAINT pk_klienci_id_klienta PRIMARY KEY ( id_klienta )
 );

ALTER TABLE klienci ADD CONSTRAINT email_or_numer_notnull CHECK ( email is not null or numer_telefonu is not null );

create sequence paczkomaty_seq start 1 increment by 1;

CREATE  TABLE paczkomaty (
	id_paczkomatu        integer DEFAULT nextval('paczkomaty_seq') NOT NULL ,
	miasto               varchar(20)  NOT NULL ,
	ulica_nr             varchar(100)  NOT NULL ,
	aktywny				 boolean DEFAULT true NOT NULL,
	CONSTRAINT pk_paczkomaty_id_paczkomatu PRIMARY KEY ( id_paczkomatu )
 );

CREATE INDEX idx_paczkomaty_miasto ON paczkomaty USING hash( miasto ) WHERE aktywny;

create view aktywne_paczkomaty as select id_paczkomatu, miasto, ulica_nr from paczkomaty where aktywny;

create sequence pracownicy_seq start 1 increment by 1;

CREATE  TABLE pracownicy (
	id_pracownika        integer DEFAULT nextval('pracownicy_seq') NOT NULL ,
	imie                 varchar(20)  NOT NULL ,
	nazwisko             varchar(20)  NOT NULL ,
	CONSTRAINT pk_pracownicy_id_pracownika PRIMARY KEY ( id_pracownika )
 );

create sequence przewozy_seq start 1 increment by 1;

CREATE  TABLE przewozy (
	id_przewozu          integer DEFAULT nextval('przewozy_seq') NOT NULL ,
	id_pracownika        integer  NOT NULL ,
	data_rozpoczecia     timestamp DEFAULT current_timestamp NOT NULL ,
	data_zakonczenia     timestamp ,
	CONSTRAINT pk_przewozy_id_przewozu PRIMARY KEY ( id_przewozu )
 );

ALTER TABLE przewozy ADD CONSTRAINT cns_przewozy CHECK ( data_rozpoczecia <= data_zakonczenia or data_zakonczenia is null );

CREATE INDEX przewozy_w_toku ON przewozy USING hash( id_pracownika ) WHERE data_zakonczenia is null;

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

create sequence paczki_seq start 1 increment by 1;

CREATE  TABLE paczki (
	id_paczki            integer DEFAULT nextval('paczki_seq') NOT NULL ,
	id_typu              integer  NOT NULL ,
	id_klasy             integer  NOT NULL ,
	id_paczkomatu_nadania integer  NOT NULL ,
	id_paczkomatu_odbioru integer  NOT NULL ,
	id_nadawcy           integer  NOT NULL ,
	id_odbiorcy          integer  NOT NULL ,
	opis                 varchar(150)   ,
	CONSTRAINT pk_paczki_id_paczki PRIMARY KEY ( id_paczki )
 );

CREATE INDEX indeks_odbiorcy ON paczki USING hash( id_odbiorcy );

CREATE INDEX indeks_nadawcy ON paczki USING hash( id_nadawcy );

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

CREATE INDEX indeks_paczki ON historia_paczek USING hash( id_paczki );

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


create or replace function insert_hash(paczka int) returns void as
$$
begin
	insert into hasze values(paczka, md5(random()::text)::varchar(20) );
end;
$$ language plpgsql;


create or replace function znajdz_pasujace_paczki( x integer, y integer, z integer ) returns int[] AS $$
begin
	return array(SELECT id_typu FROM typy WHERE
		( x <= wymiar_x AND y <= wymiar_y AND z <= wymiar_z )
	       	OR  ( y <= wymiar_x AND x <= wymiar_y AND z <= wymiar_z )
	       	OR  ( x <= wymiar_x AND z <= wymiar_y AND y <= wymiar_z )
	       	OR  ( y <= wymiar_x AND z <= wymiar_y AND x <= wymiar_z )
	       	OR  ( z <= wymiar_x AND x <= wymiar_y AND y <= wymiar_z )
	       	OR  ( z <= wymiar_x AND y <= wymiar_y AND x <= wymiar_z ) );
end;
$$ LANGUAGE plpgsql;


create or replace function paczkomat_dodaj_check(paczkomat int, paczka int) returns boolean as
$$
declare l_miejsc int;
declare zaj_miejsca int;
declare typ int;
begin
	typ=(select id_typu from paczki where id_paczki=paczka);
	l_miejsc=(select liczba_miejsc from pojemnosc_paczkomatu where id_paczkomatu=paczkomat and id_typu=typ );
	zaj_miejsca=(select count(*) from paczkomaty_paczki join paczki using(id_paczki) where id_paczkomatu=paczkomat and id_typu=typ );
	if zaj_miejsca=l_miejsc then return 'F'::boolean; end if;
	return 'T'::boolean;
end;
$$ language plpgsql;


create or replace function wez_za_stare(pracownik int, paczkomat int) returns void as
$$
declare r record;
declare nr_przewozu int := id_przewozu(pracownik);
begin
	create table tmp as (select pp.id_paczki as id from paczkomaty_paczki pp where id_paczkomatu=paczkomat and
	current_timestamp>interval '2 days' + (select max(data_zmiany) from historia_paczek hp where hp.id_paczki=pp.id_paczki) );
	for r in (select * from tmp) loop
		delete from paczkomaty_paczki where id_paczki=r.id;
		insert into historia_paczek values(r.id, 6, default);
		insert into przewozy_paczki values(nr_przewozu, r.id);
	end loop;
	drop table tmp;
end;
$$ language plpgsql;


create or replace function pracownik_active(id int) returns boolean as $$
begin
	return (select count(*) from przewozy where id_pracownika = id and data_zakonczenia is null) = 1;
end;
$$ language plpgsql;


create or replace function id_przewozu(id_prac int) returns int as $$
begin
	if pracownik_active(id_prac) = false then return -1; end if;
	return (select id_przewozu from przewozy where id_pracownika = id_prac and data_zakonczenia is null);
end;
$$ language plpgsql;


create or replace function wez_paczki_pracownik(id_prac int, id_od int, id_do int) returns void as $$
declare
	nr_przewozu int := id_przewozu(id_prac);
	paczka record;
begin
	if nr_przewozu=-1 then return; end if;
	drop table if exists tmp cascade;
	create table tmp as (select id_paczki from paczkomaty_paczki where id_paczkomatu = id_od);
	for paczka in (select id_paczki as id from tmp) loop
		if (select id_paczkomatu_odbioru from paczki where id_paczki=paczka.id) = id_do then
			insert into historia_paczek values (paczka.id, 3, default);
			insert into przewozy_paczki values (nr_przewozu, paczka.id);
			delete from paczkomaty_paczki where id_paczkomatu = id_od and id_paczki = paczka.id;
		end if;
	end loop;
	drop table tmp;
	perform wez_za_stare(id_prac,id_od);
end;
$$ language plpgsql;


create or replace function get_stan_paczki(id_p int) returns int as $$
begin
	return (select id_stanu from historia_paczek
        where id_paczki = id_p and data_zmiany = (select max(data_zmiany) from historia_paczek where id_paczki = id_p));
end;
$$ language plpgsql;


create or replace function get_opis_stanu_paczki(id_p int) returns varchar as $$
declare stan int := get_stan_paczki(id_p);
begin
	return (select stany.opis from stany where id_stanu = stan);
end;
$$ language plpgsql;


create or replace function wloz_paczki_pracownik(id_prac int, id_pacz int) returns void as $$
declare
	nr_przewozu int := id_przewozu(id_prac);
	paczka record;
begin
	if nr_przewozu = -1 then return; end if;
	drop table if exists paczki_do_oddania cascade;
	create table paczki_do_oddania as
	(select prz.id_paczki as id_paczki, pacz.id_klasy as klasa from (select id_paczki from przewozy_paczki
	where id_przewozu = nr_przewozu and get_stan_paczki(id_paczki) = 3) as prz
	join (select id_paczki, id_klasy from paczki where id_paczkomatu_odbioru = id_pacz) as pacz on prz.id_paczki = pacz.id_paczki);

	for paczka in (select id_paczki as id from paczki_do_oddania order by 2 - klasa) loop
		if paczkomat_dodaj_check(id_pacz, paczka.id) then
			insert into historia_paczek values (paczka.id, 4, default);
			insert into paczkomaty_paczki values (id_pacz, paczka.id);
			delete from przewozy_paczki where id_przewozu = nr_przewozu and id_paczki = paczka.id;
			perform insert_hash(paczka.id);
		end if;
	end loop;
	drop table paczki_do_oddania;
end;
$$ language plpgsql;


create or replace function zakoncz_przewoz(id_prac int) returns void as $$
declare
	nr_przewozu int := id_przewozu(id_prac);
begin
	insert into historia_paczek
	(select id_paczki, 6, current_timestamp from przewozy_paczki where id_przewozu = nr_przewozu and get_stan_paczki(id_paczki) != 6);
	update przewozy set data_zakonczenia = current_timestamp where id_przewozu = nr_przewozu;
end;
$$ language plpgsql;


create or replace function zmien_cena(id_t int, id_k int, new_cena numeric(6,2)) returns void as $$
begin
	update cena_klasa_typ set cena = new_cena where id_typu = id_t and id_klasy = id_k;
end;
$$ language plpgsql;


create or replace function zloz_zamowienie(id_kl int, id_t int, id_p_n int, id_p_o int, id_n int, id_o int, op varchar) returns int as $$
declare id_pacz int := nextval('paczki_seq');
begin
	insert into paczki values (id_pacz, id_t, id_kl, id_p_n, id_p_o, id_n, id_o, op);
	insert into historia_paczek values (id_pacz, 1, default);
	return id_pacz;
end;
$$ language plpgsql;


create or replace function cena_paczki(paczka int) returns numeric(6,2) as
$$
declare klient int;
declare typ int;
declare klasa int;
begin
	klient=(select id_nadawcy from paczki where id_paczki = paczka);
	typ=(select id_typu from paczki where id_paczki=paczka);
	klasa=(select id_klasy from paczki where id_paczki=paczka);
	return round( (select cena from cena_klasa_typ where id_klasy=klasa and id_typu=typ)*
	(1-0.01*coalesce( (select min(rabat) from rabaty_stale_klienci where id_klienta=klient), 0) ), 2);
end;
$$ language plpgsql;


create or replace function create_przewoz(pracownik int) returns boolean as
$$
begin
	if pracownik_active(pracownik) then return 'F'::boolean; end if;
	insert into przewozy values(default, pracownik, default, null);
	return 'T'::boolean;
end;
$$ language plpgsql;


create or replace function odbierz_paczke_klient(klient int, paczka int, hasz_odb varchar(20) ) returns boolean as
$$
begin
	if get_stan_paczki(paczka) != 4 then return 'F'::boolean; end if;
	if hasz_odb!=(select hasz from hasze where id_paczki=paczka) then return 'F'::boolean; end if;
	if klient != (select id_odbiorcy from paczki where id_paczki=paczka) then return 'F'::boolean; end if;
	delete from paczkomaty_paczki where id_paczki=paczka;
	delete from hasze where id_paczki=paczka;
	insert into historia_paczek values(paczka, 5, default);
	return 'T'::boolean;
end;
$$ language plpgsql;


create or replace function wloz_paczke_klient(klient int, paczka int) returns boolean as
$$
declare paczkomat int;
begin
	if get_stan_paczki(paczka) != 1 then return 'F'::boolean; end if;
	if klient != (select id_nadawcy from paczki where id_paczki=paczka) then return 'F'::boolean; end if;
	paczkomat=(select id_paczkomatu_nadania from paczki where id_paczki=paczka);
	if paczkomat_dodaj_check(paczkomat, paczka)='F'::boolean then return 'F'::boolean; end if;
	insert into paczkomaty_paczki values(paczkomat, paczka);
	insert into historia_paczek values(paczka, 2, default);
	return 'T'::boolean;
end;
$$ language plpgsql;


create or replace function create_klient(nazwa varchar(20), numer varchar(15), email varchar(30)) returns int as $$
declare id int := nextval('klienci_seq');
begin
	insert into klienci values (id, nazwa, numer, email);
	return id;
end;
$$ language plpgsql;


create or replace function dodaj_rabat(klient int, rabat_nowy numeric(5,2)) returns void as
$$
begin
    if klient in (select id_klienta from rabaty_stale_klienci) then
        update rabaty_stale_klienci set rabat=rabat_nowy where id_klienta=klient;
    else
        insert into rabaty_stale_klienci values(klient,rabat_nowy);
    end if;
end;
$$ language plpgsql;


create or replace function create_pracownik(imie varchar(20), nazwisko varchar(20)) returns int as $$
declare id int := nextval('pracownicy_seq');
begin
	insert into pracownicy values (id, imie, nazwisko);
	return id;
end;
$$ language plpgsql;


create or replace function create_paczkomat(miasto varchar(20), ulica_nr varchar(20)) returns int as $$
declare id int := nextval('paczkomaty_seq');
begin
	insert into paczkomaty values (id, miasto, ulica_nr, default);
	return id;
end;
$$ language plpgsql;

create or replace function get_moje_paczki_klient(id int) returns table(i int, n varchar, o varchar, i_n int, i_o int, kl varchar, op varchar, st varchar) as $$
select id_paczki,
    (select nazwa from klienci where id_klienta = id_nadawcy),
    (select nazwa from klienci where id_klienta = id_odbiorcy),
    id_paczkomatu_nadania,
    id_paczkomatu_odbioru,
    (select nazwa from klasy k where k.id_klasy = sub.id_klasy),
    opis,
    get_opis_stanu_paczki(id_paczki) from
(select id_paczki, id_nadawcy, id_odbiorcy, id_paczkomatu_nadania, id_paczkomatu_odbioru, id_klasy, opis from paczki where id_nadawcy = id or id_odbiorcy = id) as sub
$$ language sql;

create or replace function get_moje_paczki_pracownik(id int) returns table(i int, o int, d int) as $$
select id_paczki, id_paczkomatu_nadania, id_paczkomatu_odbioru from paczki where id_paczki in (select id_paczki from przewozy_paczki where id_przewozu = id_przewozu(id));
$$ language sql;

insert into klasy values
(1,'zwykla'),
(2,'premium');

insert into typy values
(1,10,20,20),
(2,20,30,30),
(3,50,50,70),
(4,30,80,80);

insert into cena_klasa_typ values
(1,1,8),
(2,1,10),
(1,2,12),
(2,2,15),
(1,3,15),
(2,3,20),
(1,4,21),
(2,4,27);

insert into pracownicy values
(default,'Jan','Kowalski'),
(default,'Adam','Nowak'),
(default, 'Tomasz', 'Krakowski'),
(default, 'Javier', 'Lewis'),
(default, 'Candace', 'Grant'),
(default, 'Leroy', 'Austin'),
(default, 'Lana', 'Norris'),
(default, 'Shawn', 'Gill'),
(default, 'Lydia', 'Becker'),
(default, 'Earl', 'Barrett'),
(default, 'Neal', 'Rios'),
(default, 'Cody', 'Fields'),
(default, 'Willie', 'Stevens'),
(default, 'Ryan', 'Curtis'),
(default, 'Jo', 'Burke'),
(default, 'Tabitha', 'Kelly'),
(default, 'Damon', 'Welch'),
(default, 'Arnold', 'Hale'),
(default, 'Toni', 'Lane'),
(default, 'Heidi', 'Greer'),
(default, 'Sheri', 'Pena'),
(default, 'Leona', 'Simpson'),
(default, 'Gertrude', 'Brown'),
(default, 'Erika', 'Richardson'),
(default, 'Elaine', 'Logan'),
(default, 'Nichole', 'Murray'),
(default, 'Pat', 'Hardy'),
(default, 'Nora', 'Hodges');

insert into klienci values
(default,'Amazon','600500400','amazon@amazon.pl'),
(default,'Jan Wojcik', '615789432', 'janwojcik@gmail.com'),
(default, 'Joanna Nowicka', '557980043', null),
(default, 'Zabawki dla dzieci', '543786100', 'zabawki@gmail.com'),
(default, 'Anna Jarosz', null, 'jaroszanna@wp.pl'),
(default, 'Andres Gardner', '871492243', 'andres@gardner.com'),
(default, 'Brooke Day', '361851920', null ),
(default, 'Jimmy Lyons', '664616603', 'jimmy@lyons.com'),
(default, 'Archie Wood', '876871731', null ),
(default, 'Julie Reynolds', '594397226', 'julie@reynolds.com'),
(default, 'Janie Boone', '147588477', 'janie@boone.com'),
(default, 'Alexandra Doyle', '089247790', 'alexandra@doyle.com'),
(default, 'Willie Bowers', '059186140', 'willie@bowers.com'),
(default, 'Amber Bush', '785731510', 'amber@bush.com'),
(default, 'Meghan Lopez', '333857615', null ),
(default, 'Nicholas Herrera', '133989492', null ),
(default, 'Olga Fitzgerald', '893338831', 'olga@fitzgerald.com'),
(default, 'Belinda Alexander', '619224776', 'belinda@alexander.com'),
(default, 'Rosalie Hines', '590949796', null ),
(default, 'Danielle Santos', '203555093', 'danielle@santos.com'),
(default, 'Dwight Rivera', '467020422', null ),
(default, 'Hugo Taylor', '193713029', null ),
(default, 'Patti Buchanan', '148575611', 'patti@buchanan.com'),
(default, 'Debra Nash', '070109192', null ),
(default, 'Madeline Massey', '090776620', null ),
(default, 'Calvin Greer', '816252334', null ),
(default, 'Ellen Wilkins', '542529097', null ),
(default, 'Wanda Vaughn', '393713989', null ),
(default, 'Dexter Duncan', '573509139', 'dexter@duncan.com'),
(default, 'Clyde Parker', '935911467', null ),
(default, 'Lynette Estrada', '461477415', null ),
(default, 'Jan May', '485758537', 'jan@may.com'),
(default, 'Lucia Colon', '395736350', null ),
(default, 'Roderick Warner', '397672279', 'roderick@warner.com'),
(default, 'Raymond Frazier', '323638744', null ),
(default, 'Alma Vega', '569720535', 'alma@vega.com'),
(default, 'Guillermo Hanson', '892941164', 'guillermo@hanson.com'),
(default, 'Seth Walker', '802875080', null ),
(default, 'Paulette Nichols', '138625168', null ),
(default, 'Lorena Bowman', '858812571', null ),
(default, 'Jean Wong', '164350135', 'jean@wong.com'),
(default, 'Greg Medina', '317652229', null ),
(default, 'Hazel Soto', '487963256', 'hazel@soto.com'),
(default, 'Jane Barton', '748656458', null ),
(default, 'Sidney Watson', '909017486', null ),
(default, 'Cary Farmer', '898838769', null ),
(default, 'Roger Zimmerman', '711517266', 'roger@zimmerman.com'),
(default, 'Jodi Leonard', '660756952', 'jodi@leonard.com'),
(default, 'Alfonso Jefferson', '311468330', 'alfonso@jefferson.com'),
(default, 'Christine Benson', '625072557', 'christine@benson.com'),
(default, 'Ernesto Nguyen', '046190462', 'ernesto@nguyen.com'),
(default, 'Gilberto Griffith', '423759893', null ),
(default, 'Roxanne Clark', '731189512', null ),
(default, 'Lillian Moreno', '420177642', 'lillian@moreno.com'),
(default, 'Milton Osborne', '190060223', null ),
(default, 'Daryl Rodriquez', '179877967', 'daryl@rodriquez.com'),
(default, 'Pam Andrews', '537028505', null ),
(default, 'Ron Delgado', '760574189', 'ron@delgado.com'),
(default, 'Gregg Patrick', '290078848', 'gregg@patrick.com'),
(default, 'Caroline Gordon', '780814150', null ),
(default, 'Franklin Howard', '959084367', null ),
(default, 'Melba Boyd', '183262330', 'melba@boyd.com'),
(default, 'Dan Barker', '022813934', 'dan@barker.com'),
(default, 'Craig Byrd', '622950191', 'craig@byrd.com'),
(default, 'Edith Ramos', '032941906', 'edith@ramos.com'),
(default, 'Otis Abbott', '226451689', null ),
(default, 'Stephanie Underwood', '294953015', null ),
(default, 'Darrin Brock', '262321345', 'darrin@brock.com'),
(default, 'Constance Gray', '189775587', 'constance@gray.com'),
(default, 'Terri Mccoy', '354545067', null ),
(default, 'Kathy Gonzalez', '674137643', null ),
(default, 'Tina Davidson', '641567546', 'tina@davidson.com'),
(default, 'Heidi Mcdonald', '336616248', 'heidi@mcdonald.com'),
(default, 'Tony Carpenter', '784211640', null ),
(default, 'Shane Becker', '633288230', null ),
(default, 'Todd Harrison', '267946558', null ),
(default, 'Nadine Pope', '618451815', 'nadine@pope.com'),
(default, 'Sheldon Lawrence', '870243932', null ),
(default, 'Lee Mckenzie', '546960105', 'lee@mckenzie.com'),
(default, 'Arthur Franklin', '748510575', null ),
(default, 'Jeff Fields', '447243889', null ),
(default, 'Darrel Huff', '827327540', null ),
(default, 'Colleen Vargas', '968577058', null ),
(default, 'Desiree Rios', '448852727', 'desiree@rios.com'),
(default, 'Oliver Black', '404508666', 'oliver@black.com'),
(default, 'Joanna Murphy', '518098591', null ),
(default, 'Clayton Horton', '880698441', null ),
(default, 'Bill Knight', '192053745', 'bill@knight.com'),
(default, 'Steve Reed', '574652561', null ),
(default, 'Jared Foster', '815941542', 'jared@foster.com'),
(default, 'Kirk Ray', '737085547', null ),
(default, 'Herman Chavez', '072939325', 'herman@chavez.com'),
(default, 'Delbert Maldonado', '678664828', null ),
(default, 'Felipe Briggs', '266984371', 'felipe@briggs.com'),
(default, 'Julia Edwards', '825311606', 'julia@edwards.com'),
(default, 'Eunice Hodges', '828223573', null ),
(default, 'Max Swanson', '653019516', 'max@swanson.com'),
(default, 'Lionel Fowler', '350275500', 'lionel@fowler.com'),
(default, 'Shirley Parks', '601475892', null ),
(default, 'Casey Cole', '279551439', null );

insert into stany values
(1, 'oczekuje nadania'),
(2, 'nadana'),
(3, 'w doreczeniu'),
(4, 'gotowa do odbioru'),
(5, 'odebrana'),
(6, 'w punkcie zbiorczym');

insert into paczkomaty values
(default,'Krakow', 'Lojasiewicza 6'),
(default,'Krakow', 'Lubicz 43'),
(default,'Tarnow','Krakowska 149'),
(default,'Kraków','ul. Kopernika Mikołaja 59'),
(default,'Warszawa','ul. Zesłańców Polskich 63'),
(default,'Jastrzębie-Zdrój','ul. Truskawkowa 100'),
(default,'Olsztyn','ul. Generała Berlinga Zygmunta 54'),
(default,'Wrocław','ul. Kraszewskiego 105'),
(default,'Szczecin','ul. Zgierska 57'),
(default,'Warszawa','ul. Anielewicza Mordechaja 89'),
(default,'Warszawa','ul. Fizyków 29'),
(default,'Opole','ul. Gomołów 42'),
(default,'Mysłowice','ul. Boliny 15'),
(default,'Jastrzębie-Zdrój','ul. Goździków 133'),
(default,'Poznań','ul. Czernika Stanisława 56'),
(default,'Olsztyn','ul. Małków Roberta i Karola 130'),
(default,'Starachowice','ul. Piłsudskiego 95'),
(default,'Warszawa','ul. Fromborska 51'),
(default,'Łódź','ul. Podmokła 36'),
(default,'Wrocław','Pl. Anielewicza Mordechaja 98'),
(default,'Łódź','ul. Nawrot 50'),
(default,'Łódź','ul. Szczytowa 16'),
(default,'Łódź','ul. Gazowa 126'),
(default,'Będzin','ul. Piaskowa 80'),
(default,'Rybnik','ul. Adamskiego 123'),
(default,'Kraków','ul. Wenecja 136'),
(default,'Dąbrowa Górnicza','ul. Żytnia 148'),
(default,'Jastrzębie-Zdrój','ul. Kraszewskiego Józefa Ignacego 134'),
(default,'Lublin','ul. Bukowa 128'),
(default,'Katowice','ul. Gliwicka 38'),
(default,'Kraków','ul. Księży Pijarów 116'),
(default,'Szczecin','ul. Śniadeckich 68'),
(default,'Poznań','ul. Piaseckiego Eugeniusza 20'),
(default,'Koszalin','ul. Krucza 13'),
(default,'Ruda Śląska','ul. Kręta 18'),
(default,'Łódź','ul. Babiego Lata 147'),
(default,'Katowice','ul. Wyciągowa 5'),
(default,'Będzin','ul. Dąbrowska 140'),
(default,'Warszawa','ul. Płatnicza 22'),
(default,'Wrocław','ul. Środkowa 30'),
(default,'Łódź','ul. Szpinakowa 126'),
(default,'Wrocław','ul. Rabczańska 21'),
(default,'Wrocław','ul. Jutrosińska 130'),
(default,'Olsztyn','ul. Profesora Poznańskiego Stefana 57'),
(default,'Katowice','ul. Podgórna 104'),
(default,'Lublin','ul. Bukietowa 85'),
(default,'Bydgoszcz','ul. Dorszowa 131'),
(default,'Racibórz','ul. Handlowa 70'),
(default,'Będzin','ul. Kamienna 93'),
(default,'Kraków','Al. Krasińskiego Zygmunta 126');


insert into pojemnosc_paczkomatu values
(1,1,20),
(1,2,15),
(2,1,30),
(2,2,20),
(3,1,30),
(3,2,20);

insert into rabaty_stale_klienci values
(1,10);
