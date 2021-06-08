
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
	for r in (select pp.id_paczki as id from paczkomaty_paczki pp where id_paczkomatu=paczkomat and
    current_timestamp>interval '2 days' + (select max(data_zmiany) from historia_paczek hp where hp.id_paczki=pp.id_paczki) ) loop
		delete from paczkomaty_paczki where id_paczki=r.id;
		insert into historia_paczek values(r.id, 6, default);
		insert into przewozy_paczki values(nr_przewozu, r.id);
	end loop;
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
	for paczka in (select id_paczki as id from (select id_paczki from paczkomaty_paczki where id_paczkomatu = id_od) as sub) loop
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
	for paczka in (select id_paczki as id from
	 (select prz.id_paczki as id_paczki, pacz.id_klasy as klasa from (select id_paczki from przewozy_paczki
     	where id_przewozu = nr_przewozu and get_stan_paczki(id_paczki) = 3) as prz
     	join (select id_paczki, id_klasy from paczki where id_paczkomatu_odbioru = id_pacz) as pacz on prz.id_paczki = pacz.id_paczki) as sub
	 order by 2 - klasa) loop
		if paczkomat_dodaj_check(id_pacz, paczka.id) then
			insert into historia_paczek values (paczka.id, 4, default);
			insert into paczkomaty_paczki values (id_pacz, paczka.id);
			perform insert_hash(paczka.id);
		end if;
	end loop;
end;
$$ language plpgsql;


create or replace function zakoncz_przewoz(id_prac int) returns void as $$
declare
	nr_przewozu int := id_przewozu(id_prac);
begin
	insert into historia_paczek
	(select id_paczki, 6, current_timestamp from przewozy_paczki where id_przewozu = nr_przewozu and get_stan_paczki(id_paczki) = 3);
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


create or replace function cena_paczki(klient int, typ int, klasa int) returns numeric(6,2) as
$$
begin
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

create or replace function get_moje_paczki_pracownik(id_prze int) returns table(i int, o int, d int) as $$
select id_paczki, id_paczkomatu_nadania, id_paczkomatu_odbioru from paczki where id_paczki in
(select id_paczki from przewozy_paczki pp where pp.id_przewozu = id_prze and get_stan_paczki(pp.id_paczki) = 3);
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
(default, 'Elaine', 'Logan');

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
(default,'Kraków', 'Lojasiewicza 6'),
(default,'Kraków', 'Lubicz 43'),
(default,'Tarnów','Krakowska 149'),
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
(1, 1, 5),
(1, 2, 15),
(1, 3, 16),
(1, 4, 11),
(2, 1, 10),
(2, 2, 1),
(2, 3, 1),
(2, 4, 19),
(3, 1, 2),
(3, 2, 9),
(3, 3, 11),
(3, 4, 5),
(4, 1, 6),
(4, 2, 3),
(4, 3, 6),
(4, 4, 13),
(5, 1, 9),
(5, 2, 18),
(5, 3, 1),
(5, 4, 17),
(6, 1, 7),
(6, 2, 15),
(6, 3, 1),
(6, 4, 10),
(7, 1, 12),
(7, 2, 10),
(7, 3, 12),
(7, 4, 6),
(8, 1, 11),
(8, 2, 1),
(8, 3, 13),
(8, 4, 2),
(9, 1, 17),
(9, 2, 9),
(9, 3, 3),
(9, 4, 12),
(10, 1, 5),
(10, 2, 14),
(10, 3, 0),
(10, 4, 7),
(11, 1, 8),
(11, 2, 13),
(11, 3, 7),
(11, 4, 11),
(12, 1, 8),
(12, 2, 7),
(12, 3, 13),
(12, 4, 1),
(13, 1, 5),
(13, 2, 8),
(13, 3, 14),
(13, 4, 3),
(14, 1, 10),
(14, 2, 10),
(14, 3, 5),
(14, 4, 17),
(15, 1, 8),
(15, 2, 0),
(15, 3, 9),
(15, 4, 19),
(16, 1, 11),
(16, 2, 18),
(16, 3, 16),
(16, 4, 8),
(17, 1, 13),
(17, 2, 2),
(17, 3, 0),
(17, 4, 0),
(18, 1, 1),
(18, 2, 4),
(18, 3, 1),
(18, 4, 14),
(19, 1, 18),
(19, 2, 7),
(19, 3, 17),
(19, 4, 6),
(20, 1, 17),
(20, 2, 9),
(20, 3, 10),
(20, 4, 16),
(21, 1, 3),
(21, 2, 18),
(21, 3, 16),
(21, 4, 2),
(22, 1, 10),
(22, 2, 7),
(22, 3, 3),
(22, 4, 2),
(23, 1, 7),
(23, 2, 4),
(23, 3, 3),
(23, 4, 1),
(24, 1, 19),
(24, 2, 11),
(24, 3, 9),
(24, 4, 4),
(25, 1, 4),
(25, 2, 17),
(25, 3, 2),
(25, 4, 16),
(26, 1, 19),
(26, 2, 13),
(26, 3, 2),
(26, 4, 0),
(27, 1, 18),
(27, 2, 5),
(27, 3, 2),
(27, 4, 9),
(28, 1, 15),
(28, 2, 3),
(28, 3, 7),
(28, 4, 4),
(29, 1, 1),
(29, 2, 13),
(29, 3, 13),
(29, 4, 6),
(30, 1, 1),
(30, 2, 12),
(30, 3, 5),
(30, 4, 8),
(31, 1, 16),
(31, 2, 7),
(31, 3, 4),
(31, 4, 13),
(32, 1, 4),
(32, 2, 0),
(32, 3, 12),
(32, 4, 14),
(33, 1, 19),
(33, 2, 9),
(33, 3, 7),
(33, 4, 6),
(34, 1, 8),
(34, 2, 10),
(34, 3, 5),
(34, 4, 2),
(35, 1, 17),
(35, 2, 12),
(35, 3, 14),
(35, 4, 12),
(36, 1, 1),
(36, 2, 10),
(36, 3, 2),
(36, 4, 17),
(37, 1, 4),
(37, 2, 18),
(37, 3, 9),
(37, 4, 6),
(38, 1, 11),
(38, 2, 5),
(38, 3, 15),
(38, 4, 11),
(39, 1, 10),
(39, 2, 0),
(39, 3, 16),
(39, 4, 0),
(40, 1, 0),
(40, 2, 5),
(40, 3, 14),
(40, 4, 1),
(41, 1, 13),
(41, 2, 2),
(41, 3, 14),
(41, 4, 10),
(42, 1, 6),
(42, 2, 13),
(42, 3, 5),
(42, 4, 19),
(43, 1, 8),
(43, 2, 0),
(43, 3, 1),
(43, 4, 4),
(44, 1, 1),
(44, 2, 18),
(44, 3, 6),
(44, 4, 4),
(45, 1, 7),
(45, 2, 6),
(45, 3, 15),
(45, 4, 19),
(46, 1, 10),
(46, 2, 11),
(46, 3, 7),
(46, 4, 1),
(47, 1, 8),
(47, 2, 16),
(47, 3, 9),
(47, 4, 5),
(48, 1, 14),
(48, 2, 17),
(48, 3, 13),
(48, 4, 13),
(49, 1, 8),
(49, 2, 15),
(49, 3, 4),
(49, 4, 1),
(50, 1, 5),
(50, 2, 3),
(50, 3, 7),
(50, 4, 9);

insert into rabaty_stale_klienci values
(1,10);

select zloz_zamowienie(2, 3, 33, 9, 1, 67, null);
select zloz_zamowienie(2, 2, 28, 16, 1, 99, null);
select zloz_zamowienie(1, 4, 30, 27, 1, 87, null);
select zloz_zamowienie(2, 3, 12, 23, 1, 17, null);
select zloz_zamowienie(2, 4, 43, 25, 1, 75, null);
select zloz_zamowienie(2, 4, 11, 47, 1, 67, null);
select zloz_zamowienie(1, 1, 38, 36, 1, 51, null);
select zloz_zamowienie(2, 2, 4, 31, 1, 73, null);
select zloz_zamowienie(1, 3, 38, 48, 1, 84, null);
select zloz_zamowienie(2, 1, 44, 5, 1, 97, null);
select zloz_zamowienie(1, 2, 43, 20, 1, 57, null);
select zloz_zamowienie(1, 1, 20, 38, 1, 22, null);
select zloz_zamowienie(2, 4, 9, 35, 1, 74, null);
select zloz_zamowienie(1, 4, 46, 1, 1, 39, null);
select zloz_zamowienie(2, 3, 5, 40, 1, 15, null);
select zloz_zamowienie(1, 2, 40, 30, 1, 23, null);
select zloz_zamowienie(1, 2, 38, 33, 1, 37, null);
select zloz_zamowienie(2, 2, 13, 32, 1, 28, null);
select zloz_zamowienie(1, 3, 37, 27, 1, 100, null);
select zloz_zamowienie(1, 1, 19, 16, 1, 11, null);
select zloz_zamowienie(1, 4, 26, 49, 2, 44, null);
select zloz_zamowienie(2, 4, 46, 24, 2, 85, null);
select zloz_zamowienie(2, 4, 25, 18, 2, 26, null);
select zloz_zamowienie(1, 4, 25, 10, 2, 20, null);
select zloz_zamowienie(1, 2, 36, 24, 2, 11, null);
select zloz_zamowienie(2, 2, 5, 17, 2, 52, null);
select zloz_zamowienie(2, 3, 46, 6, 2, 53, null);
select zloz_zamowienie(1, 3, 11, 3, 2, 89, null);
select zloz_zamowienie(2, 4, 13, 14, 2, 96, null);
select zloz_zamowienie(1, 3, 19, 50, 2, 94, null);
select zloz_zamowienie(2, 1, 32, 36, 2, 27, null);
select zloz_zamowienie(2, 4, 23, 33, 2, 79, null);
select zloz_zamowienie(2, 1, 32, 24, 2, 12, null);
select zloz_zamowienie(1, 1, 25, 4, 2, 24, null);
select zloz_zamowienie(2, 3, 26, 28, 2, 73, null);
select zloz_zamowienie(1, 1, 15, 12, 2, 60, null);
select zloz_zamowienie(1, 2, 16, 20, 2, 33, null);
select zloz_zamowienie(2, 1, 8, 15, 2, 58, null);
select zloz_zamowienie(1, 3, 39, 12, 2, 41, null);
select zloz_zamowienie(2, 2, 32, 2, 2, 82, null);
select zloz_zamowienie(1, 3, 13, 46, 3, 8, null);
select zloz_zamowienie(1, 2, 24, 21, 3, 58, null);
select zloz_zamowienie(1, 1, 42, 22, 3, 64, null);
select zloz_zamowienie(2, 2, 25, 14, 3, 13, null);
select zloz_zamowienie(1, 4, 47, 15, 3, 67, null);
select zloz_zamowienie(1, 3, 31, 37, 3, 66, null);
select zloz_zamowienie(1, 3, 20, 25, 3, 47, null);
select zloz_zamowienie(2, 1, 33, 49, 3, 79, null);
select zloz_zamowienie(1, 2, 29, 1, 3, 38, null);
select zloz_zamowienie(2, 3, 41, 30, 3, 17, null);
select zloz_zamowienie(1, 2, 7, 34, 3, 99, null);
select zloz_zamowienie(2, 4, 7, 35, 3, 15, null);
select zloz_zamowienie(2, 4, 46, 15, 3, 55, null);
select zloz_zamowienie(2, 3, 27, 14, 3, 31, null);
select zloz_zamowienie(1, 1, 17, 41, 3, 88, null);
select zloz_zamowienie(2, 4, 50, 45, 3, 39, null);
select zloz_zamowienie(1, 1, 24, 17, 3, 52, null);
select zloz_zamowienie(1, 1, 2, 39, 3, 12, null);
select zloz_zamowienie(2, 3, 8, 49, 3, 5, null);
select zloz_zamowienie(2, 3, 17, 50, 3, 46, null);
select zloz_zamowienie(2, 1, 35, 25, 4, 74, null);
select zloz_zamowienie(2, 1, 30, 2, 4, 92, null);
select zloz_zamowienie(2, 4, 14, 35, 4, 45, null);
select zloz_zamowienie(1, 4, 24, 17, 4, 43, null);
select zloz_zamowienie(1, 4, 13, 49, 4, 33, null);
select zloz_zamowienie(2, 3, 41, 3, 4, 57, null);
select zloz_zamowienie(2, 1, 7, 4, 4, 2, null);
select zloz_zamowienie(1, 3, 12, 32, 4, 17, null);
select zloz_zamowienie(1, 4, 23, 22, 4, 30, null);
select zloz_zamowienie(1, 2, 17, 13, 4, 18, null);
select zloz_zamowienie(1, 4, 13, 29, 4, 14, null);
select zloz_zamowienie(1, 3, 2, 36, 4, 24, null);
select zloz_zamowienie(2, 2, 34, 29, 4, 17, null);
select zloz_zamowienie(2, 2, 48, 37, 4, 19, null);
select zloz_zamowienie(2, 1, 30, 9, 4, 80, null);
select zloz_zamowienie(2, 2, 15, 46, 4, 60, null);
select zloz_zamowienie(2, 2, 11, 40, 4, 37, null);
select zloz_zamowienie(2, 1, 18, 38, 4, 84, null);
select zloz_zamowienie(2, 3, 47, 22, 4, 60, null);
select zloz_zamowienie(1, 1, 33, 44, 4, 94, null);
select zloz_zamowienie(1, 4, 6, 19, 5, 14, null);
select zloz_zamowienie(2, 4, 35, 29, 5, 70, null);
select zloz_zamowienie(1, 4, 20, 41, 5, 98, null);
select zloz_zamowienie(1, 3, 15, 34, 5, 35, null);
select zloz_zamowienie(1, 3, 3, 35, 5, 58, null);
select zloz_zamowienie(2, 4, 30, 33, 5, 43, null);
select zloz_zamowienie(1, 1, 35, 45, 5, 72, null);
select zloz_zamowienie(1, 2, 27, 49, 5, 46, null);
select zloz_zamowienie(1, 2, 41, 44, 5, 88, null);
select zloz_zamowienie(2, 4, 35, 19, 5, 90, null);
select zloz_zamowienie(2, 1, 35, 1, 5, 4, null);
select zloz_zamowienie(2, 3, 29, 31, 5, 71, null);
select zloz_zamowienie(2, 4, 10, 15, 5, 35, null);
select zloz_zamowienie(2, 4, 17, 46, 5, 70, null);
select zloz_zamowienie(1, 2, 21, 12, 5, 28, null);
select zloz_zamowienie(1, 4, 23, 1, 5, 1, null);
select zloz_zamowienie(1, 4, 46, 36, 5, 68, null);
select zloz_zamowienie(1, 4, 4, 30, 5, 87, null);
select zloz_zamowienie(2, 1, 28, 14, 5, 38, null);
select zloz_zamowienie(2, 3, 4, 22, 5, 54, null);
select zloz_zamowienie(2, 3, 45, 30, 6, 10, null);
select zloz_zamowienie(1, 4, 20, 25, 6, 86, null);
select zloz_zamowienie(1, 2, 43, 2, 6, 3, null);
select zloz_zamowienie(2, 4, 10, 14, 6, 50, null);
select zloz_zamowienie(2, 3, 27, 15, 6, 95, null);
select zloz_zamowienie(2, 1, 13, 31, 6, 23, null);
select zloz_zamowienie(1, 3, 47, 48, 6, 41, null);
select zloz_zamowienie(1, 1, 45, 5, 6, 78, null);
select zloz_zamowienie(1, 1, 2, 46, 6, 75, null);
select zloz_zamowienie(1, 2, 14, 44, 6, 98, null);
select zloz_zamowienie(2, 2, 6, 40, 6, 100, null);
select zloz_zamowienie(2, 1, 36, 26, 6, 74, null);
select zloz_zamowienie(2, 1, 31, 16, 6, 91, null);
select zloz_zamowienie(1, 1, 44, 38, 6, 10, null);
select zloz_zamowienie(1, 4, 25, 46, 6, 86, null);
select zloz_zamowienie(2, 1, 32, 9, 6, 35, null);
select zloz_zamowienie(2, 4, 44, 7, 6, 31, null);
select zloz_zamowienie(1, 4, 28, 37, 6, 60, null);
select zloz_zamowienie(1, 2, 27, 25, 6, 42, null);
select zloz_zamowienie(1, 1, 34, 41, 6, 12, null);
select zloz_zamowienie(1, 3, 41, 48, 7, 73, null);
select zloz_zamowienie(1, 4, 20, 19, 7, 17, null);
select zloz_zamowienie(2, 3, 42, 39, 7, 85, null);
select zloz_zamowienie(1, 3, 47, 29, 7, 81, null);
select zloz_zamowienie(2, 4, 20, 2, 7, 2, null);
select zloz_zamowienie(2, 3, 37, 46, 7, 89, null);
select zloz_zamowienie(1, 1, 5, 45, 7, 13, null);
select zloz_zamowienie(1, 1, 26, 5, 7, 70, null);
select zloz_zamowienie(1, 1, 48, 18, 7, 16, null);
select zloz_zamowienie(1, 2, 3, 46, 7, 28, null);
select zloz_zamowienie(2, 4, 19, 17, 7, 44, null);
select zloz_zamowienie(2, 3, 5, 7, 7, 68, null);
select zloz_zamowienie(2, 2, 13, 48, 7, 3, null);
select zloz_zamowienie(1, 2, 30, 50, 7, 38, null);
select zloz_zamowienie(2, 2, 7, 17, 7, 36, null);
select zloz_zamowienie(2, 4, 27, 40, 7, 4, null);
select zloz_zamowienie(1, 3, 17, 41, 7, 18, null);
select zloz_zamowienie(2, 2, 4, 1, 7, 75, null);
select zloz_zamowienie(2, 3, 9, 42, 7, 68, null);
select zloz_zamowienie(1, 1, 48, 34, 7, 19, null);
select zloz_zamowienie(1, 3, 6, 18, 8, 16, null);
select zloz_zamowienie(2, 1, 44, 29, 8, 19, null);
select zloz_zamowienie(2, 2, 28, 24, 8, 3, null);
select zloz_zamowienie(1, 4, 46, 11, 8, 98, null);
select zloz_zamowienie(1, 2, 35, 23, 8, 42, null);
select zloz_zamowienie(2, 3, 33, 3, 8, 63, null);
select zloz_zamowienie(1, 2, 25, 32, 8, 64, null);
select zloz_zamowienie(2, 4, 35, 48, 8, 32, null);
select zloz_zamowienie(1, 4, 17, 5, 8, 46, null);
select zloz_zamowienie(1, 3, 9, 43, 8, 4, null);
select zloz_zamowienie(2, 4, 21, 3, 8, 26, null);
select zloz_zamowienie(2, 2, 23, 7, 8, 76, null);
select zloz_zamowienie(2, 2, 49, 47, 8, 99, null);
select zloz_zamowienie(2, 2, 6, 50, 8, 71, null);
select zloz_zamowienie(2, 1, 22, 6, 8, 6, null);
select zloz_zamowienie(1, 1, 30, 22, 8, 20, null);
select zloz_zamowienie(1, 4, 31, 30, 8, 98, null);
select zloz_zamowienie(1, 2, 17, 6, 8, 99, null);
select zloz_zamowienie(1, 2, 32, 38, 8, 31, null);
select zloz_zamowienie(2, 4, 47, 19, 8, 77, null);
select zloz_zamowienie(2, 4, 12, 34, 9, 65, null);
select zloz_zamowienie(2, 2, 50, 28, 9, 51, null);
select zloz_zamowienie(1, 2, 9, 28, 9, 72, null);
select zloz_zamowienie(2, 4, 24, 23, 9, 89, null);
select zloz_zamowienie(1, 1, 19, 27, 9, 1, null);
select zloz_zamowienie(1, 2, 50, 24, 9, 1, null);
select zloz_zamowienie(2, 2, 13, 2, 9, 73, null);
select zloz_zamowienie(2, 3, 41, 25, 9, 38, null);
select zloz_zamowienie(2, 3, 1, 48, 9, 90, null);
select zloz_zamowienie(2, 3, 42, 28, 9, 86, null);
select zloz_zamowienie(2, 2, 25, 5, 9, 87, null);
select zloz_zamowienie(1, 4, 50, 48, 9, 49, null);
select zloz_zamowienie(1, 1, 30, 21, 9, 64, null);
select zloz_zamowienie(1, 1, 2, 46, 9, 39, null);
select zloz_zamowienie(1, 3, 15, 23, 9, 40, null);
select zloz_zamowienie(1, 3, 21, 29, 9, 23, null);
select zloz_zamowienie(1, 4, 36, 24, 9, 95, null);
select zloz_zamowienie(1, 2, 2, 7, 9, 59, null);
select zloz_zamowienie(1, 3, 25, 5, 9, 77, null);
select zloz_zamowienie(2, 2, 15, 46, 9, 23, null);
select zloz_zamowienie(2, 4, 43, 13, 10, 88, null);
select zloz_zamowienie(2, 3, 15, 39, 10, 4, null);
select zloz_zamowienie(2, 1, 41, 25, 10, 74, null);
select zloz_zamowienie(2, 3, 15, 38, 10, 6, null);
select zloz_zamowienie(2, 1, 21, 15, 10, 27, null);
select zloz_zamowienie(2, 2, 43, 23, 10, 63, null);
select zloz_zamowienie(1, 1, 29, 33, 10, 22, null);
select zloz_zamowienie(2, 1, 15, 47, 10, 51, null);
select zloz_zamowienie(2, 2, 3, 12, 10, 1, null);
select zloz_zamowienie(2, 2, 3, 24, 10, 81, null);
select zloz_zamowienie(2, 2, 11, 6, 10, 57, null);
select zloz_zamowienie(2, 3, 29, 34, 10, 4, null);
select zloz_zamowienie(2, 1, 9, 14, 10, 54, null);
select zloz_zamowienie(2, 4, 4, 48, 10, 49, null);
select zloz_zamowienie(2, 4, 35, 40, 10, 29, null);
select zloz_zamowienie(1, 1, 29, 21, 10, 4, null);
select zloz_zamowienie(1, 4, 46, 18, 10, 3, null);
select zloz_zamowienie(2, 3, 22, 26, 10, 62, null);
select zloz_zamowienie(1, 4, 10, 15, 10, 67, null);
select zloz_zamowienie(1, 1, 1, 17, 10, 3, null);
select zloz_zamowienie(1, 4, 3, 50, 11, 15, null);
select zloz_zamowienie(1, 4, 45, 17, 11, 96, null);
select zloz_zamowienie(2, 2, 22, 38, 11, 78, null);
select zloz_zamowienie(2, 4, 21, 49, 11, 46, null);
select zloz_zamowienie(1, 2, 20, 25, 11, 98, null);
select zloz_zamowienie(1, 4, 5, 50, 11, 82, null);
select zloz_zamowienie(2, 4, 39, 21, 11, 76, null);
select zloz_zamowienie(1, 2, 17, 49, 11, 56, null);
select zloz_zamowienie(1, 4, 48, 25, 11, 24, null);
select zloz_zamowienie(2, 2, 7, 27, 11, 64, null);
select zloz_zamowienie(2, 3, 38, 6, 11, 62, null);
select zloz_zamowienie(1, 3, 4, 13, 11, 28, null);
select zloz_zamowienie(1, 2, 49, 5, 11, 19, null);
select zloz_zamowienie(1, 4, 4, 15, 11, 74, null);
select zloz_zamowienie(2, 1, 15, 27, 11, 65, null);
select zloz_zamowienie(2, 3, 15, 40, 11, 6, null);
select zloz_zamowienie(1, 3, 48, 15, 11, 86, null);
select zloz_zamowienie(1, 1, 39, 14, 11, 32, null);
select zloz_zamowienie(1, 3, 20, 5, 11, 42, null);
select zloz_zamowienie(2, 3, 12, 16, 11, 6, null);
select zloz_zamowienie(2, 4, 10, 20, 12, 17, null);
select zloz_zamowienie(1, 4, 14, 40, 12, 7, null);
select zloz_zamowienie(2, 2, 11, 38, 12, 32, null);
select zloz_zamowienie(1, 4, 24, 10, 12, 84, null);
select zloz_zamowienie(1, 2, 25, 46, 12, 77, null);
select zloz_zamowienie(2, 2, 38, 8, 12, 73, null);
select zloz_zamowienie(1, 2, 1, 17, 12, 98, null);
select zloz_zamowienie(2, 3, 44, 5, 12, 7, null);
select zloz_zamowienie(2, 1, 5, 11, 12, 22, null);
select zloz_zamowienie(2, 2, 4, 30, 12, 20, null);
select zloz_zamowienie(1, 1, 2, 1, 12, 15, null);
select zloz_zamowienie(2, 2, 49, 48, 12, 35, null);
select zloz_zamowienie(1, 1, 7, 46, 12, 87, null);
select zloz_zamowienie(2, 4, 2, 21, 12, 27, null);
select zloz_zamowienie(2, 2, 3, 14, 12, 79, null);
select zloz_zamowienie(1, 1, 34, 37, 12, 17, null);
select zloz_zamowienie(1, 4, 36, 49, 12, 18, null);
select zloz_zamowienie(2, 3, 32, 46, 12, 61, null);
select zloz_zamowienie(1, 3, 31, 1, 12, 15, null);
select zloz_zamowienie(1, 3, 48, 26, 12, 76, null);
select zloz_zamowienie(1, 2, 5, 20, 13, 63, null);
select zloz_zamowienie(1, 1, 9, 38, 13, 39, null);
select zloz_zamowienie(2, 1, 36, 10, 13, 10, null);
select zloz_zamowienie(2, 1, 44, 20, 13, 29, null);
select zloz_zamowienie(1, 3, 46, 30, 13, 66, null);
select zloz_zamowienie(1, 4, 8, 49, 13, 99, null);
select zloz_zamowienie(1, 3, 29, 11, 13, 96, null);
select zloz_zamowienie(2, 3, 7, 33, 13, 34, null);
select zloz_zamowienie(2, 3, 11, 16, 13, 90, null);
select zloz_zamowienie(1, 1, 33, 27, 13, 85, null);
select zloz_zamowienie(1, 4, 1, 45, 13, 49, null);
select zloz_zamowienie(2, 4, 2, 41, 13, 60, null);
select zloz_zamowienie(2, 3, 42, 39, 13, 34, null);
select zloz_zamowienie(1, 1, 20, 31, 13, 71, null);
select zloz_zamowienie(1, 3, 42, 20, 13, 22, null);
select zloz_zamowienie(1, 2, 4, 47, 13, 98, null);
select zloz_zamowienie(2, 2, 9, 23, 13, 21, null);
select zloz_zamowienie(2, 2, 8, 11, 13, 100, null);
select zloz_zamowienie(2, 2, 32, 14, 13, 42, null);
select zloz_zamowienie(1, 3, 14, 29, 13, 18, null);
select zloz_zamowienie(1, 2, 8, 4, 14, 70, null);
select zloz_zamowienie(1, 4, 10, 13, 14, 8, null);
select zloz_zamowienie(1, 2, 43, 46, 14, 69, null);
select zloz_zamowienie(2, 3, 23, 1, 14, 5, null);
select zloz_zamowienie(1, 4, 44, 14, 14, 44, null);
select zloz_zamowienie(1, 2, 48, 37, 14, 50, null);
select zloz_zamowienie(1, 2, 31, 13, 14, 72, null);
select zloz_zamowienie(2, 3, 40, 25, 14, 27, null);
select zloz_zamowienie(1, 4, 28, 46, 14, 13, null);
select zloz_zamowienie(1, 2, 4, 13, 14, 36, null);
select zloz_zamowienie(1, 4, 1, 14, 14, 70, null);
select zloz_zamowienie(1, 2, 47, 4, 14, 35, null);
select zloz_zamowienie(2, 2, 46, 20, 14, 23, null);
select zloz_zamowienie(1, 1, 35, 11, 14, 23, null);
select zloz_zamowienie(1, 4, 23, 46, 14, 66, null);
select zloz_zamowienie(2, 3, 32, 18, 14, 89, null);
select zloz_zamowienie(2, 3, 41, 26, 14, 10, null);
select zloz_zamowienie(2, 1, 21, 14, 14, 90, null);
select zloz_zamowienie(1, 4, 24, 35, 14, 3, null);
select zloz_zamowienie(2, 4, 50, 15, 14, 82, null);
select zloz_zamowienie(1, 2, 33, 32, 15, 22, null);
select zloz_zamowienie(1, 1, 34, 1, 15, 43, null);
select zloz_zamowienie(1, 4, 50, 29, 15, 17, null);
select zloz_zamowienie(1, 1, 17, 9, 15, 96, null);
select zloz_zamowienie(1, 3, 2, 9, 15, 43, null);
select zloz_zamowienie(1, 1, 46, 38, 15, 6, null);
select zloz_zamowienie(2, 1, 34, 6, 15, 70, null);
select zloz_zamowienie(1, 1, 19, 4, 15, 70, null);
select zloz_zamowienie(1, 2, 14, 27, 15, 72, null);
select zloz_zamowienie(2, 2, 5, 39, 15, 38, null);
select zloz_zamowienie(1, 1, 17, 36, 15, 12, null);
select zloz_zamowienie(1, 2, 18, 9, 15, 41, null);
select zloz_zamowienie(1, 2, 24, 5, 15, 64, null);
select zloz_zamowienie(1, 3, 15, 24, 15, 75, null);
select zloz_zamowienie(1, 2, 19, 41, 15, 48, null);
select zloz_zamowienie(1, 2, 9, 40, 15, 51, null);
select zloz_zamowienie(2, 2, 33, 26, 15, 45, null);
select zloz_zamowienie(1, 4, 3, 43, 15, 7, null);
select zloz_zamowienie(2, 3, 3, 38, 15, 11, null);
select zloz_zamowienie(1, 1, 43, 45, 15, 4, null);
select zloz_zamowienie(2, 3, 38, 11, 16, 96, null);
select zloz_zamowienie(1, 2, 4, 44, 16, 69, null);
select zloz_zamowienie(2, 3, 47, 6, 16, 5, null);
select zloz_zamowienie(1, 1, 47, 29, 16, 81, null);
select zloz_zamowienie(2, 4, 12, 1, 16, 11, null);
select zloz_zamowienie(1, 1, 47, 34, 16, 2, null);
select zloz_zamowienie(2, 2, 28, 18, 16, 33, null);
select zloz_zamowienie(1, 4, 19, 39, 16, 49, null);
select zloz_zamowienie(1, 3, 50, 13, 16, 63, null);
select zloz_zamowienie(1, 2, 11, 28, 16, 96, null);
select zloz_zamowienie(1, 4, 6, 16, 16, 38, null);
select zloz_zamowienie(2, 3, 9, 18, 16, 59, null);
select zloz_zamowienie(1, 2, 32, 13, 16, 53, null);
select zloz_zamowienie(1, 3, 26, 39, 16, 12, null);
select zloz_zamowienie(1, 2, 21, 1, 16, 29, null);
select zloz_zamowienie(2, 2, 8, 28, 16, 12, null);
select zloz_zamowienie(2, 3, 6, 7, 16, 88, null);
select zloz_zamowienie(2, 4, 21, 32, 16, 44, null);
select zloz_zamowienie(2, 4, 14, 23, 16, 57, null);
select zloz_zamowienie(1, 2, 7, 21, 16, 27, null);
select zloz_zamowienie(2, 2, 28, 38, 17, 16, null);
select zloz_zamowienie(2, 3, 5, 33, 17, 92, null);
select zloz_zamowienie(2, 4, 17, 48, 17, 48, null);
select zloz_zamowienie(1, 3, 41, 23, 17, 73, null);
select zloz_zamowienie(1, 4, 15, 37, 17, 71, null);
select zloz_zamowienie(2, 3, 21, 44, 17, 12, null);
select zloz_zamowienie(2, 4, 33, 32, 17, 98, null);
select zloz_zamowienie(2, 3, 41, 15, 17, 4, null);
select zloz_zamowienie(1, 3, 43, 11, 17, 25, null);
select zloz_zamowienie(1, 2, 42, 46, 17, 60, null);
select zloz_zamowienie(2, 4, 12, 44, 17, 68, null);
select zloz_zamowienie(2, 4, 44, 43, 17, 64, null);
select zloz_zamowienie(2, 3, 7, 24, 17, 31, null);
select zloz_zamowienie(1, 2, 4, 9, 17, 47, null);
select zloz_zamowienie(2, 4, 22, 35, 17, 34, null);
select zloz_zamowienie(2, 3, 15, 12, 17, 6, null);
select zloz_zamowienie(2, 4, 29, 50, 17, 20, null);
select zloz_zamowienie(2, 4, 24, 3, 17, 34, null);
select zloz_zamowienie(1, 4, 30, 46, 17, 20, null);
select zloz_zamowienie(1, 1, 28, 19, 17, 76, null);
select zloz_zamowienie(2, 2, 30, 31, 18, 96, null);
select zloz_zamowienie(1, 4, 27, 23, 18, 92, null);
select zloz_zamowienie(1, 4, 18, 37, 18, 62, null);
select zloz_zamowienie(2, 4, 45, 4, 18, 14, null);
select zloz_zamowienie(2, 3, 33, 43, 18, 59, null);
select zloz_zamowienie(2, 1, 48, 26, 18, 47, null);
select zloz_zamowienie(1, 3, 33, 14, 18, 1, null);
select zloz_zamowienie(1, 4, 49, 1, 18, 75, null);
select zloz_zamowienie(2, 4, 50, 8, 18, 90, null);
select zloz_zamowienie(2, 1, 47, 4, 18, 36, null);
select zloz_zamowienie(1, 3, 42, 32, 18, 82, null);
select zloz_zamowienie(1, 2, 43, 17, 18, 31, null);
select zloz_zamowienie(2, 1, 27, 44, 18, 61, null);
select zloz_zamowienie(2, 1, 42, 7, 18, 6, null);
select zloz_zamowienie(2, 4, 31, 8, 18, 60, null);
select zloz_zamowienie(2, 4, 38, 18, 18, 42, null);
select zloz_zamowienie(1, 2, 14, 3, 18, 42, null);
select zloz_zamowienie(2, 2, 43, 42, 18, 59, null);
select zloz_zamowienie(2, 2, 25, 12, 18, 78, null);
select zloz_zamowienie(2, 3, 45, 26, 18, 37, null);
select zloz_zamowienie(2, 2, 8, 29, 19, 78, null);
select zloz_zamowienie(2, 1, 41, 11, 19, 2, null);
select zloz_zamowienie(1, 2, 35, 46, 19, 79, null);
select zloz_zamowienie(2, 3, 35, 36, 19, 94, null);
select zloz_zamowienie(1, 4, 30, 13, 19, 76, null);
select zloz_zamowienie(2, 1, 9, 24, 19, 78, null);
select zloz_zamowienie(2, 1, 7, 45, 19, 63, null);
select zloz_zamowienie(1, 1, 18, 35, 19, 36, null);
select zloz_zamowienie(1, 3, 22, 26, 19, 22, null);
select zloz_zamowienie(1, 2, 33, 40, 19, 50, null);
select zloz_zamowienie(2, 1, 29, 15, 19, 97, null);
select zloz_zamowienie(1, 4, 11, 40, 19, 55, null);
select zloz_zamowienie(2, 2, 23, 39, 19, 84, null);
select zloz_zamowienie(2, 3, 49, 44, 19, 33, null);
select zloz_zamowienie(2, 3, 47, 31, 19, 52, null);
select zloz_zamowienie(1, 2, 17, 5, 19, 2, null);
select zloz_zamowienie(2, 3, 26, 9, 19, 39, null);
select zloz_zamowienie(2, 3, 24, 47, 19, 91, null);
select zloz_zamowienie(2, 2, 47, 27, 19, 23, null);
select zloz_zamowienie(2, 4, 18, 48, 19, 76, null);
select zloz_zamowienie(1, 3, 15, 34, 20, 43, null);
select zloz_zamowienie(1, 4, 28, 20, 20, 73, null);
select zloz_zamowienie(2, 2, 6, 11, 20, 45, null);
select zloz_zamowienie(2, 3, 23, 11, 20, 56, null);
select zloz_zamowienie(2, 3, 14, 42, 20, 86, null);
select zloz_zamowienie(2, 3, 12, 15, 20, 11, null);
select zloz_zamowienie(1, 4, 36, 16, 20, 41, null);
select zloz_zamowienie(2, 1, 14, 7, 20, 44, null);
select zloz_zamowienie(1, 2, 36, 20, 20, 91, null);
select zloz_zamowienie(2, 1, 10, 14, 20, 18, null);
select zloz_zamowienie(1, 3, 27, 21, 20, 10, null);
select zloz_zamowienie(1, 1, 3, 8, 20, 46, null);
select zloz_zamowienie(1, 3, 7, 40, 20, 14, null);
select zloz_zamowienie(1, 3, 33, 40, 20, 6, null);
select zloz_zamowienie(2, 2, 31, 34, 20, 53, null);
select zloz_zamowienie(2, 2, 2, 34, 20, 76, null);
select zloz_zamowienie(1, 2, 29, 43, 20, 46, null);
select zloz_zamowienie(1, 1, 28, 42, 20, 73, null);
select zloz_zamowienie(1, 4, 6, 21, 20, 31, null);
select zloz_zamowienie(1, 1, 6, 3, 20, 25, null);
select zloz_zamowienie(1, 1, 6, 5, 21, 64, null);
select zloz_zamowienie(1, 2, 37, 46, 21, 8, null);
select zloz_zamowienie(1, 2, 41, 8, 21, 44, null);
select zloz_zamowienie(1, 4, 9, 13, 21, 25, null);
select zloz_zamowienie(1, 2, 50, 15, 21, 1, null);
select zloz_zamowienie(1, 2, 33, 50, 21, 94, null);
select zloz_zamowienie(2, 1, 41, 17, 21, 20, null);
select zloz_zamowienie(2, 3, 25, 41, 21, 56, null);
select zloz_zamowienie(1, 4, 1, 16, 21, 37, null);
select zloz_zamowienie(1, 2, 47, 33, 21, 97, null);
select zloz_zamowienie(2, 4, 15, 27, 21, 68, null);
select zloz_zamowienie(1, 2, 46, 17, 21, 87, null);
select zloz_zamowienie(1, 2, 28, 9, 21, 98, null);
select zloz_zamowienie(1, 1, 20, 10, 21, 61, null);
select zloz_zamowienie(2, 1, 21, 31, 21, 57, null);
select zloz_zamowienie(2, 4, 8, 31, 21, 1, null);
select zloz_zamowienie(2, 1, 38, 3, 21, 55, null);
select zloz_zamowienie(2, 2, 9, 34, 21, 32, null);
select zloz_zamowienie(2, 1, 27, 42, 21, 65, null);
select zloz_zamowienie(2, 4, 26, 8, 21, 89, null);
select zloz_zamowienie(2, 2, 23, 47, 22, 70, null);
select zloz_zamowienie(1, 2, 49, 14, 22, 31, null);
select zloz_zamowienie(1, 2, 35, 46, 22, 54, null);
select zloz_zamowienie(2, 3, 19, 23, 22, 23, null);
select zloz_zamowienie(2, 2, 44, 41, 22, 65, null);
select zloz_zamowienie(1, 2, 13, 3, 22, 14, null);
select zloz_zamowienie(1, 4, 46, 42, 22, 47, null);
select zloz_zamowienie(1, 3, 16, 44, 22, 14, null);
select zloz_zamowienie(1, 4, 28, 44, 22, 42, null);
select zloz_zamowienie(2, 3, 7, 15, 22, 58, null);
select zloz_zamowienie(2, 3, 3, 40, 22, 74, null);
select zloz_zamowienie(2, 2, 6, 17, 22, 65, null);
select zloz_zamowienie(2, 3, 16, 8, 22, 8, null);
select zloz_zamowienie(2, 2, 38, 21, 22, 58, null);
select zloz_zamowienie(1, 1, 26, 20, 22, 27, null);
select zloz_zamowienie(2, 3, 46, 14, 22, 67, null);
select zloz_zamowienie(1, 2, 6, 32, 22, 37, null);
select zloz_zamowienie(1, 1, 17, 23, 22, 33, null);
select zloz_zamowienie(2, 3, 29, 4, 22, 8, null);
select zloz_zamowienie(1, 3, 21, 6, 22, 77, null);
select zloz_zamowienie(1, 4, 33, 40, 23, 49, null);
select zloz_zamowienie(1, 4, 40, 29, 23, 6, null);
select zloz_zamowienie(2, 1, 21, 30, 23, 68, null);
select zloz_zamowienie(1, 4, 40, 12, 23, 73, null);
select zloz_zamowienie(2, 3, 50, 40, 23, 81, null);
select zloz_zamowienie(1, 4, 1, 24, 23, 25, null);
select zloz_zamowienie(1, 2, 16, 31, 23, 82, null);
select zloz_zamowienie(2, 1, 9, 11, 23, 41, null);
select zloz_zamowienie(1, 1, 46, 37, 23, 81, null);
select zloz_zamowienie(1, 1, 44, 29, 23, 74, null);
select zloz_zamowienie(2, 1, 29, 22, 23, 7, null);
select zloz_zamowienie(1, 1, 11, 32, 23, 20, null);
select zloz_zamowienie(1, 3, 28, 39, 23, 25, null);
select zloz_zamowienie(1, 2, 14, 25, 23, 85, null);
select zloz_zamowienie(2, 2, 2, 24, 23, 6, null);
select zloz_zamowienie(2, 3, 45, 8, 23, 68, null);
select zloz_zamowienie(1, 4, 22, 44, 23, 61, null);
select zloz_zamowienie(2, 3, 35, 36, 23, 35, null);
select zloz_zamowienie(1, 2, 38, 46, 23, 30, null);
select zloz_zamowienie(2, 3, 8, 33, 23, 17, null);
select zloz_zamowienie(2, 2, 10, 35, 24, 83, null);
select zloz_zamowienie(1, 2, 49, 16, 24, 93, null);
select zloz_zamowienie(1, 4, 16, 28, 24, 54, null);
select zloz_zamowienie(1, 3, 32, 45, 24, 77, null);
select zloz_zamowienie(1, 4, 33, 19, 24, 85, null);
select zloz_zamowienie(2, 4, 21, 23, 24, 1, null);
select zloz_zamowienie(2, 2, 38, 16, 24, 76, null);
select zloz_zamowienie(1, 3, 32, 13, 24, 63, null);
select zloz_zamowienie(2, 4, 30, 23, 24, 82, null);
select zloz_zamowienie(1, 4, 50, 22, 24, 27, null);
select zloz_zamowienie(2, 3, 49, 15, 24, 72, null);
select zloz_zamowienie(2, 4, 39, 8, 24, 85, null);
select zloz_zamowienie(2, 4, 46, 33, 24, 72, null);
select zloz_zamowienie(1, 1, 42, 37, 24, 84, null);
select zloz_zamowienie(2, 2, 26, 2, 24, 67, null);
select zloz_zamowienie(1, 2, 37, 10, 24, 68, null);
select zloz_zamowienie(1, 4, 19, 1, 24, 30, null);
select zloz_zamowienie(2, 2, 32, 26, 24, 54, null);
select zloz_zamowienie(2, 2, 25, 16, 24, 71, null);
select zloz_zamowienie(2, 1, 15, 10, 24, 74, null);
select zloz_zamowienie(2, 2, 42, 22, 25, 57, null);
select zloz_zamowienie(2, 4, 6, 39, 25, 10, null);
select zloz_zamowienie(2, 4, 4, 2, 25, 68, null);
select zloz_zamowienie(2, 1, 40, 43, 25, 64, null);
select zloz_zamowienie(2, 3, 28, 50, 25, 18, null);
select zloz_zamowienie(2, 1, 12, 32, 25, 86, null);
select zloz_zamowienie(1, 2, 10, 3, 25, 26, null);
select zloz_zamowienie(2, 1, 8, 19, 25, 54, null);
select zloz_zamowienie(2, 2, 27, 9, 25, 29, null);
select zloz_zamowienie(2, 4, 11, 23, 25, 33, null);
select zloz_zamowienie(1, 4, 10, 41, 25, 98, null);
select zloz_zamowienie(1, 3, 6, 20, 25, 2, null);
select zloz_zamowienie(1, 2, 3, 43, 25, 18, null);
select zloz_zamowienie(1, 2, 4, 6, 25, 18, null);
select zloz_zamowienie(1, 4, 24, 44, 25, 73, null);
select zloz_zamowienie(2, 3, 36, 22, 25, 40, null);
select zloz_zamowienie(1, 2, 14, 36, 25, 13, null);
select zloz_zamowienie(2, 2, 13, 3, 25, 6, null);
select zloz_zamowienie(2, 2, 38, 24, 25, 43, null);
select zloz_zamowienie(2, 1, 44, 48, 25, 52, null);
select zloz_zamowienie(2, 2, 34, 39, 26, 53, null);
select zloz_zamowienie(1, 3, 21, 31, 26, 36, null);
select zloz_zamowienie(1, 2, 22, 15, 26, 92, null);
select zloz_zamowienie(1, 3, 49, 16, 26, 10, null);
select zloz_zamowienie(1, 4, 32, 12, 26, 12, null);
select zloz_zamowienie(1, 3, 43, 21, 26, 76, null);
select zloz_zamowienie(2, 3, 32, 31, 26, 29, null);
select zloz_zamowienie(2, 4, 3, 25, 26, 91, null);
select zloz_zamowienie(2, 1, 1, 32, 26, 14, null);
select zloz_zamowienie(2, 2, 22, 46, 26, 31, null);
select zloz_zamowienie(2, 1, 33, 35, 26, 13, null);
select zloz_zamowienie(1, 4, 26, 9, 26, 93, null);
select zloz_zamowienie(2, 2, 46, 5, 26, 82, null);
select zloz_zamowienie(1, 4, 21, 29, 26, 29, null);
select zloz_zamowienie(1, 3, 10, 39, 26, 70, null);
select zloz_zamowienie(2, 1, 17, 4, 26, 31, null);
select zloz_zamowienie(2, 3, 46, 32, 26, 50, null);
select zloz_zamowienie(2, 3, 18, 34, 26, 87, null);
select zloz_zamowienie(2, 1, 48, 18, 26, 33, null);
select zloz_zamowienie(1, 3, 35, 30, 26, 8, null);
select zloz_zamowienie(1, 3, 41, 21, 27, 37, null);
select zloz_zamowienie(2, 4, 45, 9, 27, 72, null);
select zloz_zamowienie(1, 1, 33, 39, 27, 76, null);
select zloz_zamowienie(2, 2, 11, 34, 27, 23, null);
select zloz_zamowienie(1, 1, 11, 27, 27, 65, null);
select zloz_zamowienie(2, 1, 1, 16, 27, 98, null);
select zloz_zamowienie(2, 2, 30, 29, 27, 71, null);
select zloz_zamowienie(1, 3, 33, 15, 27, 97, null);
select zloz_zamowienie(1, 1, 50, 45, 27, 31, null);
select zloz_zamowienie(1, 1, 8, 35, 27, 30, null);
select zloz_zamowienie(2, 3, 9, 20, 27, 72, null);
select zloz_zamowienie(1, 2, 39, 25, 27, 51, null);
select zloz_zamowienie(2, 4, 5, 17, 27, 19, null);
select zloz_zamowienie(1, 2, 28, 19, 27, 88, null);
select zloz_zamowienie(2, 1, 26, 32, 27, 8, null);
select zloz_zamowienie(2, 1, 28, 5, 27, 33, null);
select zloz_zamowienie(1, 1, 8, 9, 27, 8, null);
select zloz_zamowienie(2, 2, 11, 44, 27, 61, null);
select zloz_zamowienie(2, 3, 23, 5, 27, 61, null);
select zloz_zamowienie(1, 4, 15, 28, 27, 59, null);
select zloz_zamowienie(2, 1, 45, 32, 28, 11, null);
select zloz_zamowienie(1, 3, 40, 24, 28, 21, null);
select zloz_zamowienie(2, 4, 4, 48, 28, 59, null);
select zloz_zamowienie(2, 1, 22, 33, 28, 92, null);
select zloz_zamowienie(1, 3, 25, 19, 28, 17, null);
select zloz_zamowienie(1, 4, 36, 15, 28, 78, null);
select zloz_zamowienie(1, 1, 3, 40, 28, 58, null);
select zloz_zamowienie(1, 1, 46, 36, 28, 4, null);
select zloz_zamowienie(1, 2, 32, 47, 28, 3, null);
select zloz_zamowienie(2, 3, 20, 14, 28, 76, null);
select zloz_zamowienie(2, 4, 35, 17, 28, 83, null);
select zloz_zamowienie(1, 1, 50, 13, 28, 55, null);
select zloz_zamowienie(2, 2, 8, 28, 28, 59, null);
select zloz_zamowienie(2, 3, 7, 13, 28, 75, null);
select zloz_zamowienie(1, 3, 36, 17, 28, 70, null);
select zloz_zamowienie(2, 3, 18, 34, 28, 83, null);
select zloz_zamowienie(1, 4, 2, 44, 28, 14, null);
select zloz_zamowienie(2, 2, 7, 8, 28, 37, null);
select zloz_zamowienie(1, 3, 12, 42, 28, 78, null);
select zloz_zamowienie(1, 2, 20, 9, 28, 39, null);
select zloz_zamowienie(1, 4, 11, 42, 29, 5, null);
select zloz_zamowienie(1, 4, 41, 10, 29, 93, null);
select zloz_zamowienie(2, 4, 11, 10, 29, 28, null);
select zloz_zamowienie(1, 1, 13, 7, 29, 72, null);
select zloz_zamowienie(1, 2, 6, 2, 29, 10, null);
select zloz_zamowienie(2, 2, 11, 18, 29, 50, null);
select zloz_zamowienie(1, 1, 38, 33, 29, 72, null);
select zloz_zamowienie(1, 4, 10, 1, 29, 20, null);
select zloz_zamowienie(1, 4, 26, 38, 29, 1, null);
select zloz_zamowienie(2, 1, 28, 45, 29, 52, null);
select zloz_zamowienie(1, 4, 37, 11, 29, 59, null);
select zloz_zamowienie(2, 4, 14, 39, 29, 18, null);
select zloz_zamowienie(1, 1, 16, 39, 29, 85, null);
select zloz_zamowienie(1, 2, 13, 27, 29, 12, null);
select zloz_zamowienie(1, 1, 13, 6, 29, 6, null);
select zloz_zamowienie(2, 2, 38, 18, 29, 57, null);
select zloz_zamowienie(2, 4, 18, 44, 29, 63, null);
select zloz_zamowienie(2, 2, 38, 25, 29, 31, null);
select zloz_zamowienie(1, 2, 32, 38, 29, 77, null);
select zloz_zamowienie(1, 1, 19, 30, 29, 67, null);
select zloz_zamowienie(2, 1, 19, 33, 30, 94, null);
select zloz_zamowienie(2, 2, 22, 47, 30, 9, null);
select zloz_zamowienie(1, 1, 47, 42, 30, 74, null);
select zloz_zamowienie(1, 3, 38, 25, 30, 1, null);
select zloz_zamowienie(2, 4, 32, 9, 30, 77, null);
select zloz_zamowienie(1, 3, 50, 35, 30, 34, null);
select zloz_zamowienie(1, 1, 11, 32, 30, 36, null);
select zloz_zamowienie(1, 4, 17, 38, 30, 98, null);
select zloz_zamowienie(2, 2, 7, 46, 30, 78, null);
select zloz_zamowienie(1, 4, 22, 35, 30, 20, null);
select zloz_zamowienie(2, 1, 20, 50, 30, 20, null);
select zloz_zamowienie(2, 2, 30, 13, 30, 87, null);
select zloz_zamowienie(2, 4, 41, 45, 30, 17, null);
select zloz_zamowienie(1, 3, 40, 25, 30, 4, null);
select zloz_zamowienie(1, 3, 39, 50, 30, 55, null);
select zloz_zamowienie(1, 1, 20, 41, 30, 69, null);
select zloz_zamowienie(1, 4, 34, 8, 30, 97, null);
select zloz_zamowienie(1, 3, 9, 39, 30, 86, null);
select zloz_zamowienie(1, 1, 37, 17, 30, 50, null);
select zloz_zamowienie(2, 2, 7, 25, 30, 10, null);
select zloz_zamowienie(2, 4, 35, 44, 31, 59, null);
select zloz_zamowienie(1, 2, 14, 29, 31, 100, null);
select zloz_zamowienie(2, 2, 36, 37, 31, 23, null);
select zloz_zamowienie(1, 1, 31, 6, 31, 19, null);
select zloz_zamowienie(1, 4, 1, 20, 31, 96, null);
select zloz_zamowienie(1, 3, 14, 16, 31, 27, null);
select zloz_zamowienie(2, 2, 10, 11, 31, 5, null);
select zloz_zamowienie(1, 3, 43, 23, 31, 27, null);
select zloz_zamowienie(2, 2, 21, 27, 31, 81, null);
select zloz_zamowienie(1, 4, 49, 44, 31, 85, null);
select zloz_zamowienie(2, 1, 4, 42, 31, 100, null);
select zloz_zamowienie(2, 2, 14, 5, 31, 18, null);
select zloz_zamowienie(1, 3, 29, 21, 31, 97, null);
select zloz_zamowienie(1, 3, 35, 24, 31, 28, null);
select zloz_zamowienie(1, 1, 37, 38, 31, 75, null);
select zloz_zamowienie(2, 1, 47, 7, 31, 61, null);
select zloz_zamowienie(1, 4, 50, 46, 31, 87, null);
select zloz_zamowienie(1, 4, 15, 10, 31, 36, null);
select zloz_zamowienie(2, 1, 30, 2, 31, 41, null);
select zloz_zamowienie(1, 2, 3, 26, 31, 60, null);
select zloz_zamowienie(2, 2, 20, 18, 32, 50, null);
select zloz_zamowienie(2, 2, 44, 18, 32, 42, null);
select zloz_zamowienie(1, 3, 28, 7, 32, 18, null);
select zloz_zamowienie(1, 3, 13, 30, 32, 61, null);
select zloz_zamowienie(2, 2, 37, 27, 32, 79, null);
select zloz_zamowienie(2, 4, 15, 43, 32, 10, null);
select zloz_zamowienie(2, 3, 49, 27, 32, 3, null);
select zloz_zamowienie(1, 2, 8, 2, 32, 42, null);
select zloz_zamowienie(2, 1, 13, 22, 32, 78, null);
select zloz_zamowienie(2, 3, 8, 49, 32, 91, null);
select zloz_zamowienie(1, 3, 6, 24, 32, 65, null);
select zloz_zamowienie(1, 4, 2, 42, 32, 42, null);
select zloz_zamowienie(1, 3, 11, 9, 32, 57, null);
select zloz_zamowienie(2, 2, 9, 12, 32, 31, null);
select zloz_zamowienie(2, 1, 7, 39, 32, 73, null);
select zloz_zamowienie(2, 3, 24, 46, 32, 81, null);
select zloz_zamowienie(1, 3, 19, 6, 32, 13, null);
select zloz_zamowienie(1, 2, 38, 1, 32, 63, null);
select zloz_zamowienie(1, 2, 21, 42, 32, 59, null);
select zloz_zamowienie(1, 4, 2, 6, 32, 60, null);
select zloz_zamowienie(2, 1, 18, 26, 33, 88, null);
select zloz_zamowienie(1, 4, 46, 7, 33, 95, null);
select zloz_zamowienie(1, 2, 39, 25, 33, 14, null);
select zloz_zamowienie(2, 1, 41, 8, 33, 73, null);
select zloz_zamowienie(2, 3, 47, 15, 33, 36, null);
select zloz_zamowienie(2, 4, 24, 35, 33, 83, null);
select zloz_zamowienie(2, 3, 43, 37, 33, 17, null);
select zloz_zamowienie(2, 3, 44, 12, 33, 82, null);
select zloz_zamowienie(1, 1, 48, 25, 33, 49, null);
select zloz_zamowienie(2, 1, 5, 14, 33, 44, null);
select zloz_zamowienie(2, 2, 10, 32, 33, 69, null);
select zloz_zamowienie(1, 1, 21, 7, 33, 58, null);
select zloz_zamowienie(2, 4, 19, 24, 33, 53, null);
select zloz_zamowienie(1, 3, 17, 23, 33, 45, null);
select zloz_zamowienie(1, 3, 11, 48, 33, 30, null);
select zloz_zamowienie(2, 4, 6, 9, 33, 75, null);
select zloz_zamowienie(2, 4, 35, 3, 33, 27, null);
select zloz_zamowienie(2, 1, 2, 1, 33, 90, null);
select zloz_zamowienie(1, 3, 5, 29, 33, 90, null);
select zloz_zamowienie(2, 1, 19, 43, 33, 85, null);
select zloz_zamowienie(2, 1, 31, 23, 34, 70, null);
select zloz_zamowienie(2, 1, 26, 29, 34, 28, null);
select zloz_zamowienie(2, 3, 15, 9, 34, 74, null);
select zloz_zamowienie(1, 2, 33, 31, 34, 93, null);
select zloz_zamowienie(2, 2, 32, 43, 34, 26, null);
select zloz_zamowienie(2, 3, 45, 6, 34, 25, null);
select zloz_zamowienie(2, 1, 16, 19, 34, 79, null);
select zloz_zamowienie(2, 2, 47, 5, 34, 48, null);
select zloz_zamowienie(1, 3, 12, 42, 34, 84, null);
select zloz_zamowienie(2, 1, 35, 4, 34, 39, null);
select zloz_zamowienie(2, 2, 14, 38, 34, 86, null);
select zloz_zamowienie(1, 3, 31, 1, 34, 60, null);
select zloz_zamowienie(2, 4, 10, 7, 34, 80, null);
select zloz_zamowienie(1, 3, 19, 48, 34, 28, null);
select zloz_zamowienie(1, 4, 46, 7, 34, 11, null);
select zloz_zamowienie(1, 2, 12, 42, 34, 80, null);
select zloz_zamowienie(2, 3, 28, 8, 34, 77, null);
select zloz_zamowienie(2, 2, 46, 48, 34, 90, null);
select zloz_zamowienie(1, 1, 13, 41, 34, 39, null);
select zloz_zamowienie(2, 2, 49, 47, 34, 15, null);
select zloz_zamowienie(1, 4, 31, 38, 35, 27, null);
select zloz_zamowienie(1, 3, 46, 44, 35, 59, null);
select zloz_zamowienie(1, 2, 26, 10, 35, 12, null);
select zloz_zamowienie(1, 3, 20, 50, 35, 41, null);
select zloz_zamowienie(1, 2, 6, 16, 35, 51, null);
select zloz_zamowienie(1, 4, 14, 17, 35, 82, null);
select zloz_zamowienie(1, 1, 49, 10, 35, 19, null);
select zloz_zamowienie(2, 3, 6, 33, 35, 4, null);
select zloz_zamowienie(2, 2, 48, 39, 35, 34, null);
select zloz_zamowienie(2, 3, 33, 3, 35, 97, null);
select zloz_zamowienie(1, 2, 2, 9, 35, 68, null);
select zloz_zamowienie(2, 1, 6, 4, 35, 50, null);
select zloz_zamowienie(2, 2, 41, 11, 35, 99, null);
select zloz_zamowienie(2, 1, 17, 24, 35, 76, null);
select zloz_zamowienie(2, 4, 29, 42, 35, 20, null);
select zloz_zamowienie(1, 4, 30, 36, 35, 81, null);
select zloz_zamowienie(2, 3, 28, 46, 35, 39, null);
select zloz_zamowienie(1, 1, 31, 49, 35, 37, null);
select zloz_zamowienie(2, 4, 50, 36, 35, 29, null);
select zloz_zamowienie(1, 2, 50, 46, 35, 12, null);
select zloz_zamowienie(1, 2, 40, 31, 36, 99, null);
select zloz_zamowienie(2, 3, 47, 31, 36, 71, null);
select zloz_zamowienie(2, 2, 19, 44, 36, 59, null);
select zloz_zamowienie(1, 3, 4, 11, 36, 73, null);
select zloz_zamowienie(2, 2, 12, 35, 36, 17, null);
select zloz_zamowienie(1, 1, 27, 48, 36, 58, null);
select zloz_zamowienie(2, 3, 6, 37, 36, 27, null);
select zloz_zamowienie(2, 3, 7, 4, 36, 52, null);
select zloz_zamowienie(2, 3, 41, 7, 36, 80, null);
select zloz_zamowienie(1, 2, 18, 16, 36, 2, null);
select zloz_zamowienie(1, 1, 34, 33, 36, 20, null);
select zloz_zamowienie(2, 4, 47, 27, 36, 23, null);
select zloz_zamowienie(2, 4, 38, 11, 36, 42, null);
select zloz_zamowienie(1, 4, 39, 38, 36, 21, null);
select zloz_zamowienie(1, 2, 35, 1, 36, 87, null);
select zloz_zamowienie(1, 3, 1, 15, 36, 71, null);
select zloz_zamowienie(1, 4, 12, 25, 36, 4, null);
select zloz_zamowienie(1, 3, 31, 30, 36, 27, null);
select zloz_zamowienie(2, 3, 48, 43, 36, 28, null);
select zloz_zamowienie(1, 4, 16, 22, 36, 19, null);
select zloz_zamowienie(1, 2, 2, 28, 37, 8, null);
select zloz_zamowienie(2, 4, 14, 12, 37, 4, null);
select zloz_zamowienie(2, 2, 35, 8, 37, 28, null);
select zloz_zamowienie(2, 4, 29, 18, 37, 18, null);
select zloz_zamowienie(1, 1, 7, 11, 37, 68, null);
select zloz_zamowienie(1, 1, 15, 16, 37, 16, null);
select zloz_zamowienie(2, 4, 43, 48, 37, 94, null);
select zloz_zamowienie(2, 3, 12, 9, 37, 81, null);
select zloz_zamowienie(2, 2, 5, 10, 37, 39, null);
select zloz_zamowienie(2, 4, 29, 38, 37, 44, null);
select zloz_zamowienie(1, 1, 4, 31, 37, 12, null);
select zloz_zamowienie(1, 3, 32, 47, 37, 22, null);
select zloz_zamowienie(1, 3, 17, 19, 37, 43, null);
select zloz_zamowienie(1, 3, 44, 34, 37, 17, null);
select zloz_zamowienie(2, 3, 47, 27, 37, 45, null);
select zloz_zamowienie(2, 4, 21, 37, 37, 48, null);
select zloz_zamowienie(2, 1, 5, 31, 37, 21, null);
select zloz_zamowienie(2, 3, 6, 8, 37, 22, null);
select zloz_zamowienie(2, 4, 37, 47, 37, 77, null);
select zloz_zamowienie(2, 4, 1, 39, 37, 36, null);
select zloz_zamowienie(2, 2, 32, 43, 38, 41, null);
select zloz_zamowienie(1, 2, 17, 21, 38, 6, null);
select zloz_zamowienie(1, 4, 29, 19, 38, 88, null);
select zloz_zamowienie(1, 4, 27, 42, 38, 34, null);
select zloz_zamowienie(1, 3, 38, 1, 38, 20, null);
select zloz_zamowienie(1, 4, 6, 3, 38, 91, null);
select zloz_zamowienie(2, 3, 7, 5, 38, 50, null);
select zloz_zamowienie(2, 1, 9, 12, 38, 37, null);
select zloz_zamowienie(2, 4, 25, 47, 38, 48, null);
select zloz_zamowienie(1, 2, 46, 5, 38, 84, null);
select zloz_zamowienie(1, 3, 43, 10, 38, 46, null);
select zloz_zamowienie(1, 1, 48, 14, 38, 27, null);
select zloz_zamowienie(2, 3, 35, 14, 38, 46, null);
select zloz_zamowienie(1, 3, 20, 19, 38, 50, null);
select zloz_zamowienie(2, 2, 47, 16, 38, 93, null);
select zloz_zamowienie(1, 2, 22, 4, 38, 100, null);
select zloz_zamowienie(2, 1, 24, 37, 38, 19, null);
select zloz_zamowienie(2, 1, 13, 25, 38, 98, null);
select zloz_zamowienie(1, 3, 43, 2, 38, 86, null);
select zloz_zamowienie(2, 1, 46, 5, 38, 55, null);
select zloz_zamowienie(2, 4, 21, 19, 39, 88, null);
select zloz_zamowienie(2, 4, 36, 46, 39, 38, null);
select zloz_zamowienie(2, 2, 1, 6, 39, 42, null);
select zloz_zamowienie(2, 2, 30, 49, 39, 20, null);
select zloz_zamowienie(1, 3, 20, 19, 39, 5, null);
select zloz_zamowienie(2, 2, 3, 23, 39, 47, null);
select zloz_zamowienie(2, 1, 8, 17, 39, 76, null);
select zloz_zamowienie(1, 3, 47, 38, 39, 14, null);
select zloz_zamowienie(2, 3, 25, 26, 39, 74, null);
select zloz_zamowienie(1, 2, 38, 32, 39, 72, null);
select zloz_zamowienie(2, 3, 26, 11, 39, 83, null);
select zloz_zamowienie(2, 2, 27, 10, 39, 94, null);
select zloz_zamowienie(1, 2, 7, 8, 39, 40, null);
select zloz_zamowienie(2, 1, 19, 30, 39, 64, null);
select zloz_zamowienie(2, 1, 10, 22, 39, 35, null);
select zloz_zamowienie(2, 4, 17, 20, 39, 83, null);
select zloz_zamowienie(2, 4, 23, 1, 39, 61, null);
select zloz_zamowienie(1, 4, 18, 5, 39, 91, null);
select zloz_zamowienie(1, 2, 9, 11, 39, 17, null);
select zloz_zamowienie(1, 3, 38, 46, 39, 56, null);
select zloz_zamowienie(2, 2, 42, 38, 40, 2, null);
select zloz_zamowienie(1, 2, 17, 19, 40, 41, null);
select zloz_zamowienie(2, 2, 48, 42, 40, 99, null);
select zloz_zamowienie(1, 2, 7, 11, 40, 23, null);
select zloz_zamowienie(2, 2, 38, 41, 40, 49, null);
select zloz_zamowienie(1, 3, 7, 3, 40, 80, null);
select zloz_zamowienie(2, 1, 7, 22, 40, 35, null);
select zloz_zamowienie(2, 3, 29, 48, 40, 57, null);
select zloz_zamowienie(2, 3, 25, 37, 40, 53, null);
select zloz_zamowienie(2, 3, 48, 4, 40, 18, null);
select zloz_zamowienie(2, 3, 10, 14, 40, 64, null);
select zloz_zamowienie(2, 2, 18, 50, 40, 1, null);
select zloz_zamowienie(1, 1, 49, 1, 40, 80, null);
select zloz_zamowienie(2, 3, 4, 25, 40, 34, null);
select zloz_zamowienie(1, 4, 39, 41, 40, 4, null);
select zloz_zamowienie(2, 3, 11, 8, 40, 33, null);
select zloz_zamowienie(2, 4, 43, 39, 40, 11, null);
select zloz_zamowienie(1, 3, 3, 22, 40, 97, null);
select zloz_zamowienie(1, 4, 39, 46, 40, 98, null);
select zloz_zamowienie(2, 2, 12, 13, 40, 54, null);
select zloz_zamowienie(2, 3, 18, 4, 41, 76, null);
select zloz_zamowienie(1, 4, 26, 3, 41, 30, null);
select zloz_zamowienie(2, 4, 16, 15, 41, 46, null);
select zloz_zamowienie(1, 2, 21, 35, 41, 32, null);
select zloz_zamowienie(2, 3, 8, 48, 41, 75, null);
select zloz_zamowienie(1, 2, 15, 17, 41, 2, null);
select zloz_zamowienie(1, 4, 2, 23, 41, 74, null);
select zloz_zamowienie(1, 1, 2, 20, 41, 63, null);
select zloz_zamowienie(2, 4, 29, 15, 41, 69, null);
select zloz_zamowienie(2, 2, 37, 34, 41, 67, null);
select zloz_zamowienie(1, 1, 43, 27, 41, 1, null);
select zloz_zamowienie(1, 2, 19, 42, 41, 56, null);
select zloz_zamowienie(2, 3, 5, 22, 41, 86, null);
select zloz_zamowienie(2, 4, 25, 12, 41, 16, null);
select zloz_zamowienie(1, 1, 1, 15, 41, 71, null);
select zloz_zamowienie(1, 4, 12, 5, 41, 87, null);
select zloz_zamowienie(1, 3, 28, 46, 41, 24, null);
select zloz_zamowienie(1, 4, 28, 39, 41, 59, null);
select zloz_zamowienie(1, 1, 16, 15, 41, 91, null);
select zloz_zamowienie(2, 4, 42, 23, 41, 30, null);
select zloz_zamowienie(1, 3, 47, 19, 42, 13, null);
select zloz_zamowienie(1, 2, 24, 11, 42, 74, null);
select zloz_zamowienie(1, 3, 50, 44, 42, 20, null);
select zloz_zamowienie(1, 4, 11, 27, 42, 68, null);
select zloz_zamowienie(2, 4, 37, 38, 42, 15, null);
select zloz_zamowienie(2, 2, 18, 44, 42, 84, null);
select zloz_zamowienie(2, 3, 31, 21, 42, 21, null);
select zloz_zamowienie(2, 2, 38, 48, 42, 95, null);
select zloz_zamowienie(1, 4, 34, 8, 42, 56, null);
select zloz_zamowienie(2, 4, 43, 22, 42, 76, null);
select zloz_zamowienie(2, 3, 34, 25, 42, 85, null);
select zloz_zamowienie(1, 1, 50, 42, 42, 23, null);
select zloz_zamowienie(2, 4, 6, 25, 42, 10, null);
select zloz_zamowienie(2, 2, 36, 4, 42, 91, null);
select zloz_zamowienie(1, 2, 46, 35, 42, 72, null);
select zloz_zamowienie(2, 3, 28, 4, 42, 78, null);
select zloz_zamowienie(2, 4, 23, 7, 42, 91, null);
select zloz_zamowienie(1, 1, 23, 12, 42, 1, null);
select zloz_zamowienie(2, 3, 14, 45, 42, 19, null);
select zloz_zamowienie(2, 3, 42, 20, 42, 34, null);
select zloz_zamowienie(1, 1, 43, 36, 43, 79, null);
select zloz_zamowienie(2, 4, 37, 7, 43, 60, null);
select zloz_zamowienie(2, 3, 36, 24, 43, 19, null);
select zloz_zamowienie(1, 1, 17, 38, 43, 1, null);
select zloz_zamowienie(1, 2, 48, 14, 43, 57, null);
select zloz_zamowienie(2, 3, 30, 34, 43, 27, null);
select zloz_zamowienie(1, 4, 48, 43, 43, 13, null);
select zloz_zamowienie(1, 4, 35, 2, 43, 30, null);
select zloz_zamowienie(1, 3, 32, 2, 43, 18, null);
select zloz_zamowienie(2, 3, 25, 38, 43, 30, null);
select zloz_zamowienie(1, 4, 47, 34, 43, 74, null);
select zloz_zamowienie(1, 4, 16, 8, 43, 61, null);
select zloz_zamowienie(2, 4, 47, 41, 43, 40, null);
select zloz_zamowienie(1, 1, 4, 26, 43, 29, null);
select zloz_zamowienie(2, 4, 29, 3, 43, 90, null);
select zloz_zamowienie(2, 4, 14, 39, 43, 19, null);
select zloz_zamowienie(2, 1, 6, 3, 43, 25, null);
select zloz_zamowienie(2, 4, 7, 34, 43, 26, null);
select zloz_zamowienie(2, 4, 26, 45, 43, 15, null);
select zloz_zamowienie(2, 3, 28, 2, 43, 31, null);
select zloz_zamowienie(1, 3, 31, 50, 44, 22, null);
select zloz_zamowienie(2, 4, 23, 11, 44, 27, null);
select zloz_zamowienie(1, 4, 34, 47, 44, 66, null);
select zloz_zamowienie(1, 2, 45, 3, 44, 64, null);
select zloz_zamowienie(2, 4, 14, 37, 44, 98, null);
select zloz_zamowienie(2, 3, 31, 4, 44, 49, null);
select zloz_zamowienie(2, 2, 32, 35, 44, 87, null);
select zloz_zamowienie(2, 3, 4, 19, 44, 99, null);
select zloz_zamowienie(1, 2, 49, 33, 44, 31, null);
select zloz_zamowienie(1, 2, 40, 29, 44, 1, null);
select zloz_zamowienie(1, 2, 40, 17, 44, 27, null);
select zloz_zamowienie(2, 4, 2, 29, 44, 18, null);
select zloz_zamowienie(2, 4, 42, 6, 44, 57, null);
select zloz_zamowienie(2, 3, 2, 33, 44, 41, null);
select zloz_zamowienie(2, 3, 32, 35, 44, 96, null);
select zloz_zamowienie(1, 1, 31, 36, 44, 93, null);
select zloz_zamowienie(1, 2, 3, 19, 44, 96, null);
select zloz_zamowienie(2, 3, 34, 17, 44, 85, null);
select zloz_zamowienie(2, 2, 29, 13, 44, 2, null);
select zloz_zamowienie(1, 4, 36, 9, 44, 94, null);
select zloz_zamowienie(2, 3, 16, 22, 45, 71, null);
select zloz_zamowienie(1, 4, 16, 12, 45, 91, null);
select zloz_zamowienie(2, 2, 5, 10, 45, 18, null);
select zloz_zamowienie(2, 2, 5, 24, 45, 16, null);
select zloz_zamowienie(1, 4, 5, 7, 45, 6, null);
select zloz_zamowienie(1, 4, 49, 30, 45, 49, null);
select zloz_zamowienie(1, 4, 27, 43, 45, 86, null);
select zloz_zamowienie(1, 4, 38, 4, 45, 62, null);
select zloz_zamowienie(1, 4, 45, 8, 45, 51, null);
select zloz_zamowienie(1, 4, 45, 25, 45, 30, null);
select zloz_zamowienie(2, 4, 18, 40, 45, 70, null);
select zloz_zamowienie(1, 2, 45, 36, 45, 99, null);
select zloz_zamowienie(2, 4, 28, 3, 45, 7, null);
select zloz_zamowienie(2, 2, 39, 45, 45, 99, null);
select zloz_zamowienie(2, 1, 25, 11, 45, 15, null);
select zloz_zamowienie(2, 1, 18, 42, 45, 72, null);
select zloz_zamowienie(2, 3, 42, 5, 45, 99, null);
select zloz_zamowienie(2, 1, 16, 3, 45, 85, null);
select zloz_zamowienie(2, 4, 19, 28, 45, 83, null);
select zloz_zamowienie(1, 4, 7, 43, 45, 54, null);
select zloz_zamowienie(2, 2, 36, 28, 46, 92, null);
select zloz_zamowienie(1, 3, 16, 32, 46, 94, null);
select zloz_zamowienie(1, 3, 6, 50, 46, 59, null);
select zloz_zamowienie(2, 1, 27, 17, 46, 87, null);
select zloz_zamowienie(2, 2, 12, 25, 46, 36, null);
select zloz_zamowienie(1, 3, 31, 20, 46, 51, null);
select zloz_zamowienie(1, 1, 42, 5, 46, 10, null);
select zloz_zamowienie(1, 3, 37, 23, 46, 27, null);
select zloz_zamowienie(1, 2, 38, 29, 46, 86, null);
select zloz_zamowienie(2, 4, 34, 33, 46, 58, null);
select zloz_zamowienie(2, 1, 2, 31, 46, 71, null);
select zloz_zamowienie(2, 2, 50, 25, 46, 4, null);
select zloz_zamowienie(1, 1, 45, 23, 46, 9, null);
select zloz_zamowienie(2, 4, 35, 20, 46, 65, null);
select zloz_zamowienie(1, 1, 37, 16, 46, 18, null);
select zloz_zamowienie(2, 3, 5, 35, 46, 55, null);
select zloz_zamowienie(2, 3, 1, 22, 46, 61, null);
select zloz_zamowienie(2, 4, 4, 32, 46, 26, null);
select zloz_zamowienie(2, 2, 42, 26, 46, 20, null);
select zloz_zamowienie(1, 4, 19, 24, 46, 81, null);
select zloz_zamowienie(2, 3, 12, 34, 47, 68, null);
select zloz_zamowienie(1, 4, 16, 38, 47, 84, null);
select zloz_zamowienie(2, 3, 27, 17, 47, 32, null);
select zloz_zamowienie(1, 2, 20, 15, 47, 55, null);
select zloz_zamowienie(1, 2, 33, 17, 47, 46, null);
select zloz_zamowienie(1, 4, 6, 3, 47, 34, null);
select zloz_zamowienie(2, 2, 45, 21, 47, 87, null);
select zloz_zamowienie(2, 3, 6, 47, 47, 80, null);
select zloz_zamowienie(2, 2, 28, 5, 47, 26, null);
select zloz_zamowienie(1, 2, 6, 17, 47, 85, null);
select zloz_zamowienie(1, 2, 44, 47, 47, 38, null);
select zloz_zamowienie(1, 3, 32, 12, 47, 11, null);
select zloz_zamowienie(2, 3, 49, 38, 47, 25, null);
select zloz_zamowienie(1, 1, 39, 22, 47, 33, null);
select zloz_zamowienie(1, 2, 30, 32, 47, 100, null);
select zloz_zamowienie(2, 4, 28, 9, 47, 54, null);
select zloz_zamowienie(1, 1, 18, 26, 47, 31, null);
select zloz_zamowienie(1, 1, 42, 23, 47, 96, null);
select zloz_zamowienie(2, 4, 26, 5, 47, 82, null);
select zloz_zamowienie(2, 4, 38, 40, 47, 34, null);
select zloz_zamowienie(2, 2, 36, 1, 48, 83, null);
select zloz_zamowienie(1, 1, 45, 6, 48, 26, null);
select zloz_zamowienie(2, 3, 4, 38, 48, 10, null);
select zloz_zamowienie(2, 3, 35, 4, 48, 44, null);
select zloz_zamowienie(1, 3, 23, 15, 48, 99, null);
select zloz_zamowienie(2, 3, 46, 45, 48, 95, null);
select zloz_zamowienie(2, 3, 26, 50, 48, 86, null);
select zloz_zamowienie(2, 2, 38, 15, 48, 71, null);
select zloz_zamowienie(2, 1, 46, 16, 48, 51, null);
select zloz_zamowienie(2, 2, 43, 23, 48, 54, null);
select zloz_zamowienie(1, 3, 11, 15, 48, 52, null);
select zloz_zamowienie(2, 3, 25, 14, 48, 30, null);
select zloz_zamowienie(2, 1, 11, 21, 48, 7, null);
select zloz_zamowienie(2, 3, 29, 31, 48, 35, null);
select zloz_zamowienie(2, 1, 5, 48, 48, 53, null);
select zloz_zamowienie(2, 1, 42, 10, 48, 40, null);
select zloz_zamowienie(2, 3, 32, 31, 48, 32, null);
select zloz_zamowienie(2, 3, 3, 8, 48, 40, null);
select zloz_zamowienie(2, 4, 18, 36, 48, 65, null);
select zloz_zamowienie(2, 1, 32, 23, 48, 56, null);
select zloz_zamowienie(2, 2, 18, 13, 49, 83, null);
select zloz_zamowienie(1, 4, 12, 33, 49, 48, null);
select zloz_zamowienie(2, 4, 17, 6, 49, 14, null);
select zloz_zamowienie(2, 3, 48, 23, 49, 90, null);
select zloz_zamowienie(2, 4, 46, 30, 49, 75, null);
select zloz_zamowienie(2, 2, 22, 31, 49, 27, null);
select zloz_zamowienie(2, 1, 39, 14, 49, 73, null);
select zloz_zamowienie(2, 3, 39, 50, 49, 99, null);
select zloz_zamowienie(2, 1, 5, 15, 49, 48, null);
select zloz_zamowienie(2, 4, 45, 36, 49, 10, null);
select zloz_zamowienie(1, 2, 17, 39, 49, 4, null);
select zloz_zamowienie(2, 1, 1, 31, 49, 79, null);
select zloz_zamowienie(2, 1, 2, 8, 49, 56, null);
select zloz_zamowienie(1, 1, 27, 20, 49, 44, null);
select zloz_zamowienie(1, 4, 16, 28, 49, 86, null);
select zloz_zamowienie(2, 3, 30, 6, 49, 84, null);
select zloz_zamowienie(2, 3, 19, 36, 49, 23, null);
select zloz_zamowienie(1, 3, 24, 43, 49, 39, null);
select zloz_zamowienie(1, 1, 36, 30, 49, 38, null);
select zloz_zamowienie(1, 1, 5, 32, 49, 51, null);
select zloz_zamowienie(2, 3, 44, 36, 50, 52, null);
select zloz_zamowienie(2, 3, 29, 14, 50, 70, null);
select zloz_zamowienie(2, 1, 35, 10, 50, 45, null);
select zloz_zamowienie(1, 2, 22, 43, 50, 34, null);
select zloz_zamowienie(1, 1, 1, 25, 50, 35, null);
select zloz_zamowienie(2, 1, 23, 50, 50, 78, null);
select zloz_zamowienie(2, 2, 2, 37, 50, 60, null);
select zloz_zamowienie(2, 1, 4, 7, 50, 26, null);
select zloz_zamowienie(1, 3, 30, 26, 50, 73, null);
select zloz_zamowienie(1, 1, 15, 46, 50, 91, null);
select zloz_zamowienie(1, 4, 44, 18, 50, 29, null);
select zloz_zamowienie(1, 1, 2, 19, 50, 96, null);
select zloz_zamowienie(1, 1, 19, 49, 50, 60, null);
select zloz_zamowienie(1, 2, 28, 10, 50, 6, null);
select zloz_zamowienie(1, 4, 49, 35, 50, 35, null);
select zloz_zamowienie(1, 4, 49, 28, 50, 15, null);
select zloz_zamowienie(2, 1, 14, 35, 50, 23, null);
select zloz_zamowienie(1, 1, 24, 14, 50, 52, null);
select zloz_zamowienie(2, 4, 5, 27, 50, 83, null);
select zloz_zamowienie(2, 3, 25, 15, 50, 83, null);
select zloz_zamowienie(1, 4, 38, 34, 51, 25, null);
select zloz_zamowienie(1, 1, 2, 50, 51, 75, null);
select zloz_zamowienie(1, 1, 38, 43, 51, 53, null);
select zloz_zamowienie(1, 3, 14, 10, 51, 9, null);
select zloz_zamowienie(2, 1, 7, 50, 51, 48, null);
select zloz_zamowienie(1, 2, 39, 35, 51, 71, null);
select zloz_zamowienie(1, 1, 4, 16, 51, 87, null);
select zloz_zamowienie(1, 1, 35, 25, 51, 76, null);
select zloz_zamowienie(1, 1, 39, 36, 51, 73, null);
select zloz_zamowienie(2, 2, 4, 50, 51, 71, null);
select zloz_zamowienie(1, 4, 38, 43, 51, 26, null);
select zloz_zamowienie(2, 2, 12, 5, 51, 36, null);
select zloz_zamowienie(1, 4, 38, 50, 51, 79, null);
select zloz_zamowienie(2, 1, 10, 18, 51, 56, null);
select zloz_zamowienie(2, 2, 50, 37, 51, 6, null);
select zloz_zamowienie(2, 2, 14, 19, 51, 21, null);
select zloz_zamowienie(1, 4, 39, 14, 51, 94, null);
select zloz_zamowienie(2, 4, 43, 28, 51, 84, null);
select zloz_zamowienie(2, 3, 41, 27, 51, 71, null);
select zloz_zamowienie(1, 4, 47, 27, 51, 100, null);
select zloz_zamowienie(1, 2, 45, 16, 52, 15, null);
select zloz_zamowienie(2, 2, 10, 28, 52, 37, null);
select zloz_zamowienie(2, 2, 7, 41, 52, 76, null);
select zloz_zamowienie(2, 2, 44, 26, 52, 88, null);
select zloz_zamowienie(2, 4, 31, 23, 52, 89, null);
select zloz_zamowienie(2, 4, 49, 44, 52, 9, null);
select zloz_zamowienie(1, 1, 28, 41, 52, 1, null);
select zloz_zamowienie(1, 2, 45, 40, 52, 31, null);
select zloz_zamowienie(1, 3, 36, 37, 52, 26, null);
select zloz_zamowienie(1, 3, 11, 4, 52, 72, null);
select zloz_zamowienie(1, 1, 46, 37, 52, 27, null);
select zloz_zamowienie(1, 4, 45, 28, 52, 3, null);
select zloz_zamowienie(1, 4, 33, 35, 52, 89, null);
select zloz_zamowienie(1, 4, 5, 45, 52, 36, null);
select zloz_zamowienie(2, 1, 6, 20, 52, 36, null);
select zloz_zamowienie(1, 1, 50, 21, 52, 54, null);
select zloz_zamowienie(2, 1, 15, 44, 52, 84, null);
select zloz_zamowienie(1, 4, 4, 33, 52, 27, null);
select zloz_zamowienie(2, 1, 45, 32, 52, 60, null);
select zloz_zamowienie(1, 2, 14, 33, 52, 23, null);
select zloz_zamowienie(1, 2, 27, 39, 53, 55, null);
select zloz_zamowienie(1, 3, 44, 19, 53, 82, null);
select zloz_zamowienie(2, 1, 19, 40, 53, 59, null);
select zloz_zamowienie(1, 1, 24, 26, 53, 6, null);
select zloz_zamowienie(1, 1, 30, 49, 53, 23, null);
select zloz_zamowienie(2, 1, 46, 29, 53, 73, null);
select zloz_zamowienie(2, 4, 2, 18, 53, 72, null);
select zloz_zamowienie(1, 4, 15, 33, 53, 58, null);
select zloz_zamowienie(2, 3, 31, 18, 53, 3, null);
select zloz_zamowienie(2, 4, 19, 26, 53, 60, null);
select zloz_zamowienie(2, 1, 36, 34, 53, 39, null);
select zloz_zamowienie(2, 1, 12, 40, 53, 17, null);
select zloz_zamowienie(1, 2, 28, 37, 53, 63, null);
select zloz_zamowienie(1, 3, 2, 50, 53, 11, null);
select zloz_zamowienie(1, 2, 2, 16, 53, 79, null);
select zloz_zamowienie(1, 2, 47, 26, 53, 94, null);
select zloz_zamowienie(2, 3, 40, 31, 53, 35, null);
select zloz_zamowienie(1, 3, 16, 41, 53, 90, null);
select zloz_zamowienie(1, 3, 28, 19, 53, 5, null);
select zloz_zamowienie(1, 3, 32, 29, 53, 90, null);
select zloz_zamowienie(1, 1, 10, 29, 54, 77, null);
select zloz_zamowienie(2, 1, 3, 5, 54, 49, null);
select zloz_zamowienie(1, 1, 3, 35, 54, 1, null);
select zloz_zamowienie(2, 2, 14, 3, 54, 16, null);
select zloz_zamowienie(2, 1, 43, 9, 54, 47, null);
select zloz_zamowienie(1, 4, 25, 42, 54, 41, null);
select zloz_zamowienie(2, 4, 14, 10, 54, 85, null);
select zloz_zamowienie(2, 1, 32, 31, 54, 71, null);
select zloz_zamowienie(2, 1, 50, 20, 54, 21, null);
select zloz_zamowienie(1, 2, 21, 41, 54, 27, null);
select zloz_zamowienie(2, 3, 1, 33, 54, 78, null);
select zloz_zamowienie(1, 2, 22, 1, 54, 97, null);
select zloz_zamowienie(2, 2, 29, 35, 54, 69, null);
select zloz_zamowienie(2, 1, 17, 4, 54, 63, null);
select zloz_zamowienie(1, 1, 37, 11, 54, 3, null);
select zloz_zamowienie(2, 2, 43, 38, 54, 76, null);
select zloz_zamowienie(1, 4, 12, 31, 54, 77, null);
select zloz_zamowienie(1, 3, 48, 49, 54, 22, null);
select zloz_zamowienie(1, 3, 3, 17, 54, 14, null);
select zloz_zamowienie(1, 3, 19, 9, 54, 72, null);
select zloz_zamowienie(1, 4, 48, 18, 55, 8, null);
select zloz_zamowienie(1, 4, 23, 37, 55, 88, null);
select zloz_zamowienie(2, 2, 47, 19, 55, 6, null);
select zloz_zamowienie(2, 4, 36, 21, 55, 47, null);
select zloz_zamowienie(2, 1, 16, 8, 55, 43, null);
select zloz_zamowienie(2, 4, 1, 22, 55, 79, null);
select zloz_zamowienie(2, 1, 44, 42, 55, 17, null);
select zloz_zamowienie(2, 2, 3, 11, 55, 64, null);
select zloz_zamowienie(2, 4, 2, 49, 55, 95, null);
select zloz_zamowienie(2, 2, 25, 40, 55, 3, null);
select zloz_zamowienie(2, 1, 47, 36, 55, 4, null);
select zloz_zamowienie(1, 2, 9, 1, 55, 49, null);
select zloz_zamowienie(1, 2, 46, 17, 55, 45, null);
select zloz_zamowienie(1, 2, 34, 13, 55, 97, null);
select zloz_zamowienie(2, 1, 48, 49, 55, 37, null);
select zloz_zamowienie(2, 4, 19, 43, 55, 9, null);
select zloz_zamowienie(2, 3, 48, 43, 55, 98, null);
select zloz_zamowienie(1, 4, 9, 45, 55, 21, null);
select zloz_zamowienie(1, 4, 24, 23, 55, 95, null);
select zloz_zamowienie(2, 1, 9, 30, 55, 67, null);
select zloz_zamowienie(1, 3, 18, 20, 56, 86, null);
select zloz_zamowienie(1, 2, 46, 20, 56, 81, null);
select zloz_zamowienie(2, 1, 50, 16, 56, 24, null);
select zloz_zamowienie(2, 1, 40, 15, 56, 95, null);
select zloz_zamowienie(1, 4, 43, 17, 56, 95, null);
select zloz_zamowienie(2, 2, 10, 38, 56, 55, null);
select zloz_zamowienie(1, 2, 50, 5, 56, 68, null);
select zloz_zamowienie(2, 3, 38, 45, 56, 65, null);
select zloz_zamowienie(1, 3, 32, 12, 56, 82, null);
select zloz_zamowienie(2, 3, 42, 3, 56, 58, null);
select zloz_zamowienie(1, 1, 26, 21, 56, 11, null);
select zloz_zamowienie(2, 2, 29, 43, 56, 42, null);
select zloz_zamowienie(2, 3, 9, 36, 56, 69, null);
select zloz_zamowienie(1, 4, 34, 26, 56, 37, null);
select zloz_zamowienie(2, 2, 9, 41, 56, 96, null);
select zloz_zamowienie(1, 3, 28, 21, 56, 1, null);
select zloz_zamowienie(1, 2, 46, 27, 56, 5, null);
select zloz_zamowienie(2, 3, 39, 28, 56, 32, null);
select zloz_zamowienie(1, 4, 27, 39, 56, 81, null);
select zloz_zamowienie(1, 1, 28, 17, 56, 61, null);
select zloz_zamowienie(2, 3, 43, 26, 57, 20, null);
select zloz_zamowienie(2, 1, 37, 21, 57, 92, null);
select zloz_zamowienie(1, 1, 32, 1, 57, 53, null);
select zloz_zamowienie(2, 4, 1, 28, 57, 9, null);
select zloz_zamowienie(2, 1, 15, 16, 57, 84, null);
select zloz_zamowienie(1, 4, 34, 23, 57, 85, null);
select zloz_zamowienie(1, 3, 49, 32, 57, 86, null);
select zloz_zamowienie(2, 3, 45, 31, 57, 88, null);
select zloz_zamowienie(2, 3, 10, 28, 57, 92, null);
select zloz_zamowienie(1, 2, 2, 42, 57, 21, null);
select zloz_zamowienie(1, 4, 10, 42, 57, 21, null);
select zloz_zamowienie(2, 3, 25, 34, 57, 80, null);
select zloz_zamowienie(1, 2, 8, 26, 57, 82, null);
select zloz_zamowienie(2, 4, 26, 29, 57, 71, null);
select zloz_zamowienie(1, 3, 33, 42, 57, 14, null);
select zloz_zamowienie(1, 4, 30, 8, 57, 12, null);
select zloz_zamowienie(2, 2, 24, 48, 57, 2, null);
select zloz_zamowienie(2, 2, 27, 3, 57, 66, null);
select zloz_zamowienie(1, 4, 28, 14, 57, 100, null);
select zloz_zamowienie(1, 2, 46, 31, 57, 35, null);
select zloz_zamowienie(1, 2, 46, 4, 58, 80, null);
select zloz_zamowienie(2, 4, 8, 17, 58, 60, null);
select zloz_zamowienie(2, 3, 46, 42, 58, 38, null);
select zloz_zamowienie(1, 4, 27, 33, 58, 24, null);
select zloz_zamowienie(2, 3, 37, 12, 58, 74, null);
select zloz_zamowienie(1, 2, 47, 25, 58, 49, null);
select zloz_zamowienie(2, 1, 34, 29, 58, 12, null);
select zloz_zamowienie(2, 3, 1, 16, 58, 57, null);
select zloz_zamowienie(1, 2, 17, 40, 58, 5, null);
select zloz_zamowienie(1, 1, 26, 19, 58, 50, null);
select zloz_zamowienie(1, 2, 16, 17, 58, 89, null);
select zloz_zamowienie(1, 4, 9, 44, 58, 10, null);
select zloz_zamowienie(1, 3, 31, 20, 58, 17, null);
select zloz_zamowienie(1, 1, 50, 18, 58, 56, null);
select zloz_zamowienie(2, 2, 3, 30, 58, 39, null);
select zloz_zamowienie(1, 3, 3, 36, 58, 12, null);
select zloz_zamowienie(1, 3, 4, 6, 58, 54, null);
select zloz_zamowienie(1, 4, 43, 28, 58, 76, null);
select zloz_zamowienie(2, 3, 49, 44, 58, 57, null);
select zloz_zamowienie(1, 4, 50, 25, 58, 88, null);
select zloz_zamowienie(1, 2, 21, 38, 59, 71, null);
select zloz_zamowienie(2, 2, 37, 18, 59, 95, null);
select zloz_zamowienie(1, 3, 36, 31, 59, 77, null);
select zloz_zamowienie(2, 3, 3, 20, 59, 73, null);
select zloz_zamowienie(2, 1, 48, 2, 59, 69, null);
select zloz_zamowienie(1, 3, 7, 34, 59, 81, null);
select zloz_zamowienie(2, 2, 41, 31, 59, 65, null);
select zloz_zamowienie(1, 2, 4, 25, 59, 55, null);
select zloz_zamowienie(1, 3, 3, 50, 59, 90, null);
select zloz_zamowienie(2, 1, 23, 10, 59, 30, null);
select zloz_zamowienie(2, 1, 14, 49, 59, 2, null);
select zloz_zamowienie(2, 4, 48, 45, 59, 21, null);
select zloz_zamowienie(2, 2, 48, 49, 59, 46, null);
select zloz_zamowienie(2, 1, 39, 6, 59, 29, null);
select zloz_zamowienie(1, 3, 12, 5, 59, 21, null);
select zloz_zamowienie(1, 2, 14, 23, 59, 54, null);
select zloz_zamowienie(2, 4, 7, 1, 59, 73, null);
select zloz_zamowienie(2, 2, 8, 35, 59, 97, null);
select zloz_zamowienie(2, 4, 7, 30, 59, 17, null);
select zloz_zamowienie(1, 2, 49, 16, 59, 53, null);
select zloz_zamowienie(1, 4, 35, 9, 60, 49, null);
select zloz_zamowienie(2, 2, 40, 20, 60, 55, null);
select zloz_zamowienie(2, 4, 10, 19, 60, 57, null);
select zloz_zamowienie(1, 4, 39, 7, 60, 90, null);
select zloz_zamowienie(1, 4, 14, 41, 60, 71, null);
select zloz_zamowienie(1, 4, 19, 38, 60, 64, null);
select zloz_zamowienie(2, 1, 2, 30, 60, 21, null);
select zloz_zamowienie(2, 3, 19, 45, 60, 19, null);
select zloz_zamowienie(2, 3, 50, 43, 60, 63, null);
select zloz_zamowienie(2, 3, 15, 38, 60, 67, null);
select zloz_zamowienie(1, 4, 12, 1, 60, 79, null);
select zloz_zamowienie(1, 3, 28, 41, 60, 64, null);
select zloz_zamowienie(1, 4, 50, 27, 60, 72, null);
select zloz_zamowienie(1, 2, 16, 35, 60, 16, null);
select zloz_zamowienie(2, 2, 42, 22, 60, 30, null);
select zloz_zamowienie(1, 3, 47, 9, 60, 88, null);
select zloz_zamowienie(1, 4, 11, 49, 60, 25, null);
select zloz_zamowienie(1, 3, 21, 42, 60, 58, null);
select zloz_zamowienie(2, 2, 19, 45, 60, 17, null);
select zloz_zamowienie(2, 1, 29, 28, 60, 93, null);
select zloz_zamowienie(2, 4, 3, 15, 61, 43, null);
select zloz_zamowienie(1, 1, 26, 29, 61, 69, null);
select zloz_zamowienie(1, 1, 9, 4, 61, 58, null);
select zloz_zamowienie(1, 4, 19, 14, 61, 74, null);
select zloz_zamowienie(1, 4, 41, 50, 61, 87, null);
select zloz_zamowienie(2, 2, 38, 29, 61, 35, null);
select zloz_zamowienie(1, 3, 15, 42, 61, 73, null);
select zloz_zamowienie(2, 4, 10, 38, 61, 55, null);
select zloz_zamowienie(1, 2, 20, 48, 61, 78, null);
select zloz_zamowienie(1, 3, 24, 30, 61, 4, null);
select zloz_zamowienie(1, 3, 38, 3, 61, 28, null);
select zloz_zamowienie(1, 4, 2, 18, 61, 6, null);
select zloz_zamowienie(1, 2, 34, 21, 61, 30, null);
select zloz_zamowienie(2, 2, 15, 16, 61, 51, null);
select zloz_zamowienie(2, 1, 9, 24, 61, 2, null);
select zloz_zamowienie(2, 3, 45, 24, 61, 48, null);
select zloz_zamowienie(1, 4, 41, 15, 61, 43, null);
select zloz_zamowienie(2, 1, 46, 3, 61, 88, null);
select zloz_zamowienie(2, 3, 13, 12, 61, 28, null);
select zloz_zamowienie(2, 2, 11, 7, 61, 30, null);
select zloz_zamowienie(1, 3, 32, 40, 62, 16, null);
select zloz_zamowienie(1, 3, 16, 37, 62, 90, null);
select zloz_zamowienie(1, 4, 28, 33, 62, 96, null);
select zloz_zamowienie(1, 2, 10, 22, 62, 86, null);
select zloz_zamowienie(2, 4, 4, 46, 62, 67, null);
select zloz_zamowienie(2, 1, 31, 46, 62, 35, null);
select zloz_zamowienie(1, 2, 11, 35, 62, 2, null);
select zloz_zamowienie(2, 3, 38, 5, 62, 41, null);
select zloz_zamowienie(2, 4, 5, 26, 62, 14, null);
select zloz_zamowienie(1, 1, 31, 38, 62, 46, null);
select zloz_zamowienie(1, 2, 15, 47, 62, 4, null);
select zloz_zamowienie(2, 1, 45, 38, 62, 39, null);
select zloz_zamowienie(2, 3, 9, 38, 62, 17, null);
select zloz_zamowienie(2, 1, 44, 37, 62, 68, null);
select zloz_zamowienie(1, 4, 19, 48, 62, 31, null);
select zloz_zamowienie(2, 2, 39, 1, 62, 2, null);
select zloz_zamowienie(1, 4, 12, 2, 62, 56, null);
select zloz_zamowienie(2, 4, 23, 30, 62, 74, null);
select zloz_zamowienie(1, 2, 15, 12, 62, 2, null);
select zloz_zamowienie(2, 3, 12, 15, 62, 8, null);
select zloz_zamowienie(1, 1, 18, 30, 63, 21, null);
select zloz_zamowienie(2, 3, 37, 18, 63, 72, null);
select zloz_zamowienie(2, 4, 18, 46, 63, 15, null);
select zloz_zamowienie(2, 4, 43, 48, 63, 5, null);
select zloz_zamowienie(2, 2, 48, 27, 63, 81, null);
select zloz_zamowienie(1, 2, 34, 36, 63, 67, null);
select zloz_zamowienie(2, 4, 15, 1, 63, 71, null);
select zloz_zamowienie(2, 3, 25, 22, 63, 10, null);
select zloz_zamowienie(1, 1, 17, 21, 63, 100, null);
select zloz_zamowienie(1, 4, 37, 14, 63, 26, null);
select zloz_zamowienie(2, 4, 49, 25, 63, 36, null);
select zloz_zamowienie(2, 1, 29, 41, 63, 22, null);
select zloz_zamowienie(1, 3, 14, 38, 63, 80, null);
select zloz_zamowienie(2, 1, 6, 41, 63, 68, null);
select zloz_zamowienie(1, 3, 36, 31, 63, 82, null);
select zloz_zamowienie(2, 3, 32, 36, 63, 81, null);
select zloz_zamowienie(1, 2, 5, 31, 63, 83, null);
select zloz_zamowienie(1, 3, 49, 10, 63, 39, null);
select zloz_zamowienie(1, 4, 10, 18, 63, 76, null);
select zloz_zamowienie(2, 4, 13, 8, 63, 95, null);
select zloz_zamowienie(2, 2, 13, 2, 64, 87, null);
select zloz_zamowienie(1, 1, 22, 32, 64, 14, null);
select zloz_zamowienie(2, 1, 43, 13, 64, 50, null);
select zloz_zamowienie(2, 2, 23, 26, 64, 87, null);
select zloz_zamowienie(1, 1, 34, 45, 64, 66, null);
select zloz_zamowienie(1, 3, 31, 36, 64, 11, null);
select zloz_zamowienie(1, 1, 42, 49, 64, 36, null);
select zloz_zamowienie(2, 3, 15, 5, 64, 34, null);
select zloz_zamowienie(1, 3, 44, 14, 64, 83, null);
select zloz_zamowienie(1, 2, 3, 34, 64, 18, null);
select zloz_zamowienie(2, 1, 16, 18, 64, 49, null);
select zloz_zamowienie(2, 3, 49, 13, 64, 6, null);
select zloz_zamowienie(2, 4, 15, 36, 64, 60, null);
select zloz_zamowienie(1, 4, 24, 29, 64, 72, null);
select zloz_zamowienie(1, 1, 2, 48, 64, 77, null);
select zloz_zamowienie(1, 1, 1, 21, 64, 8, null);
select zloz_zamowienie(2, 2, 3, 13, 64, 96, null);
select zloz_zamowienie(1, 2, 9, 19, 64, 73, null);
select zloz_zamowienie(2, 3, 34, 19, 64, 5, null);
select zloz_zamowienie(2, 4, 13, 35, 64, 37, null);
select zloz_zamowienie(2, 4, 18, 12, 65, 10, null);
select zloz_zamowienie(2, 4, 10, 3, 65, 77, null);
select zloz_zamowienie(2, 4, 8, 37, 65, 52, null);
select zloz_zamowienie(2, 2, 35, 40, 65, 50, null);
select zloz_zamowienie(1, 2, 31, 11, 65, 94, null);
select zloz_zamowienie(2, 1, 25, 36, 65, 55, null);
select zloz_zamowienie(2, 2, 35, 11, 65, 97, null);
select zloz_zamowienie(1, 3, 12, 45, 65, 5, null);
select zloz_zamowienie(1, 3, 33, 7, 65, 42, null);
select zloz_zamowienie(1, 4, 37, 50, 65, 80, null);
select zloz_zamowienie(2, 4, 29, 23, 65, 36, null);
select zloz_zamowienie(2, 2, 31, 8, 65, 46, null);
select zloz_zamowienie(1, 3, 40, 32, 65, 70, null);
select zloz_zamowienie(2, 2, 48, 27, 65, 24, null);
select zloz_zamowienie(1, 4, 35, 26, 65, 94, null);
select zloz_zamowienie(1, 1, 9, 25, 65, 48, null);
select zloz_zamowienie(2, 3, 2, 38, 65, 64, null);
select zloz_zamowienie(1, 2, 48, 17, 65, 15, null);
select zloz_zamowienie(2, 2, 32, 37, 65, 61, null);
select zloz_zamowienie(2, 4, 48, 35, 65, 8, null);
select zloz_zamowienie(2, 4, 35, 39, 66, 55, null);
select zloz_zamowienie(2, 3, 22, 24, 66, 10, null);
select zloz_zamowienie(1, 4, 34, 15, 66, 83, null);
select zloz_zamowienie(2, 4, 35, 32, 66, 85, null);
select zloz_zamowienie(2, 3, 2, 14, 66, 89, null);
select zloz_zamowienie(2, 2, 45, 11, 66, 19, null);
select zloz_zamowienie(1, 3, 13, 47, 66, 72, null);
select zloz_zamowienie(1, 3, 3, 15, 66, 55, null);
select zloz_zamowienie(1, 4, 42, 18, 66, 62, null);
select zloz_zamowienie(2, 3, 46, 18, 66, 16, null);
select zloz_zamowienie(1, 2, 34, 47, 66, 45, null);
select zloz_zamowienie(2, 3, 26, 18, 66, 82, null);
select zloz_zamowienie(2, 3, 44, 18, 66, 95, null);
select zloz_zamowienie(1, 2, 28, 36, 66, 68, null);
select zloz_zamowienie(2, 1, 1, 22, 66, 27, null);
select zloz_zamowienie(2, 1, 13, 23, 66, 46, null);
select zloz_zamowienie(2, 1, 35, 24, 66, 60, null);
select zloz_zamowienie(2, 2, 29, 14, 66, 6, null);
select zloz_zamowienie(1, 2, 50, 24, 66, 55, null);
select zloz_zamowienie(2, 1, 43, 16, 66, 4, null);
select zloz_zamowienie(2, 1, 43, 38, 67, 46, null);
select zloz_zamowienie(2, 2, 23, 13, 67, 96, null);
select zloz_zamowienie(1, 4, 17, 28, 67, 83, null);
select zloz_zamowienie(2, 2, 34, 21, 67, 80, null);
select zloz_zamowienie(1, 2, 37, 44, 67, 24, null);
select zloz_zamowienie(2, 2, 31, 50, 67, 9, null);
select zloz_zamowienie(1, 1, 28, 8, 67, 80, null);
select zloz_zamowienie(2, 3, 49, 32, 67, 96, null);
select zloz_zamowienie(1, 3, 24, 32, 67, 7, null);
select zloz_zamowienie(1, 1, 15, 14, 67, 61, null);
select zloz_zamowienie(2, 2, 42, 12, 67, 33, null);
select zloz_zamowienie(1, 3, 5, 47, 67, 83, null);
select zloz_zamowienie(1, 2, 12, 42, 67, 51, null);
select zloz_zamowienie(1, 2, 11, 19, 67, 89, null);
select zloz_zamowienie(1, 2, 49, 41, 67, 90, null);
select zloz_zamowienie(2, 1, 45, 40, 67, 50, null);
select zloz_zamowienie(2, 2, 27, 15, 67, 72, null);
select zloz_zamowienie(1, 1, 19, 33, 67, 91, null);
select zloz_zamowienie(1, 2, 46, 6, 67, 33, null);
select zloz_zamowienie(2, 4, 36, 37, 67, 21, null);
select zloz_zamowienie(2, 2, 2, 46, 68, 97, null);
select zloz_zamowienie(1, 4, 49, 10, 68, 58, null);
select zloz_zamowienie(1, 4, 22, 18, 68, 86, null);
select zloz_zamowienie(2, 4, 35, 31, 68, 63, null);
select zloz_zamowienie(1, 3, 49, 41, 68, 86, null);
select zloz_zamowienie(2, 4, 13, 21, 68, 92, null);
select zloz_zamowienie(2, 3, 47, 29, 68, 55, null);
select zloz_zamowienie(2, 3, 19, 47, 68, 7, null);
select zloz_zamowienie(1, 4, 12, 36, 68, 39, null);
select zloz_zamowienie(2, 1, 43, 49, 68, 84, null);
select zloz_zamowienie(1, 3, 46, 8, 68, 43, null);
select zloz_zamowienie(1, 1, 19, 4, 68, 17, null);
select zloz_zamowienie(2, 4, 14, 17, 68, 15, null);
select zloz_zamowienie(2, 1, 31, 12, 68, 30, null);
select zloz_zamowienie(1, 3, 17, 43, 68, 88, null);
select zloz_zamowienie(1, 3, 37, 5, 68, 43, null);
select zloz_zamowienie(1, 1, 13, 10, 68, 13, null);
select zloz_zamowienie(1, 3, 33, 42, 68, 81, null);
select zloz_zamowienie(1, 3, 24, 33, 68, 49, null);
select zloz_zamowienie(2, 2, 15, 20, 68, 89, null);
select zloz_zamowienie(1, 3, 11, 38, 69, 19, null);
select zloz_zamowienie(1, 2, 33, 17, 69, 19, null);
select zloz_zamowienie(1, 3, 3, 26, 69, 74, null);
select zloz_zamowienie(1, 1, 49, 29, 69, 92, null);
select zloz_zamowienie(2, 4, 22, 37, 69, 51, null);
select zloz_zamowienie(2, 1, 2, 4, 69, 9, null);
select zloz_zamowienie(2, 3, 7, 25, 69, 31, null);
select zloz_zamowienie(1, 4, 20, 32, 69, 73, null);
select zloz_zamowienie(1, 1, 41, 48, 69, 44, null);
select zloz_zamowienie(1, 2, 35, 42, 69, 45, null);
select zloz_zamowienie(1, 1, 11, 18, 69, 93, null);
select zloz_zamowienie(1, 1, 14, 34, 69, 33, null);
select zloz_zamowienie(2, 4, 30, 47, 69, 28, null);
select zloz_zamowienie(2, 2, 33, 35, 69, 85, null);
select zloz_zamowienie(1, 1, 30, 12, 69, 15, null);
select zloz_zamowienie(2, 2, 4, 35, 69, 26, null);
select zloz_zamowienie(1, 3, 1, 11, 69, 96, null);
select zloz_zamowienie(2, 4, 40, 24, 69, 33, null);
select zloz_zamowienie(2, 1, 3, 42, 69, 11, null);
select zloz_zamowienie(1, 4, 22, 6, 69, 99, null);
select zloz_zamowienie(2, 3, 24, 47, 70, 53, null);
select zloz_zamowienie(1, 3, 38, 19, 70, 98, null);
select zloz_zamowienie(2, 3, 44, 17, 70, 21, null);
select zloz_zamowienie(1, 1, 16, 25, 70, 4, null);
select zloz_zamowienie(1, 4, 15, 45, 70, 97, null);
select zloz_zamowienie(1, 4, 11, 9, 70, 87, null);
select zloz_zamowienie(2, 4, 36, 14, 70, 41, null);
select zloz_zamowienie(2, 2, 48, 6, 70, 82, null);
select zloz_zamowienie(1, 3, 31, 15, 70, 16, null);
select zloz_zamowienie(1, 4, 46, 4, 70, 19, null);
select zloz_zamowienie(2, 3, 4, 30, 70, 66, null);
select zloz_zamowienie(1, 4, 25, 47, 70, 75, null);
select zloz_zamowienie(2, 3, 8, 38, 70, 66, null);
select zloz_zamowienie(2, 4, 22, 15, 70, 62, null);
select zloz_zamowienie(2, 4, 29, 45, 70, 62, null);
select zloz_zamowienie(2, 2, 23, 3, 70, 59, null);
select zloz_zamowienie(1, 1, 22, 12, 70, 8, null);
select zloz_zamowienie(2, 4, 15, 2, 70, 99, null);
select zloz_zamowienie(2, 1, 34, 47, 70, 18, null);
select zloz_zamowienie(1, 4, 3, 4, 70, 10, null);
select zloz_zamowienie(2, 3, 29, 6, 71, 30, null);
select zloz_zamowienie(1, 3, 28, 7, 71, 7, null);
select zloz_zamowienie(1, 2, 39, 8, 71, 98, null);
select zloz_zamowienie(2, 4, 4, 13, 71, 82, null);
select zloz_zamowienie(1, 1, 6, 13, 71, 39, null);
select zloz_zamowienie(2, 2, 18, 4, 71, 90, null);
select zloz_zamowienie(1, 2, 10, 45, 71, 23, null);
select zloz_zamowienie(2, 3, 27, 44, 71, 78, null);
select zloz_zamowienie(2, 4, 31, 2, 71, 40, null);
select zloz_zamowienie(1, 2, 30, 33, 71, 14, null);
select zloz_zamowienie(1, 1, 37, 48, 71, 69, null);
select zloz_zamowienie(2, 4, 43, 41, 71, 34, null);
select zloz_zamowienie(2, 1, 32, 40, 71, 19, null);
select zloz_zamowienie(2, 1, 32, 15, 71, 44, null);
select zloz_zamowienie(2, 2, 22, 5, 71, 11, null);
select zloz_zamowienie(2, 2, 6, 21, 71, 38, null);
select zloz_zamowienie(1, 4, 15, 10, 71, 21, null);
select zloz_zamowienie(1, 4, 8, 1, 71, 8, null);
select zloz_zamowienie(2, 4, 29, 21, 71, 46, null);
select zloz_zamowienie(1, 1, 5, 46, 71, 81, null);
select zloz_zamowienie(2, 4, 16, 21, 72, 6, null);
select zloz_zamowienie(1, 3, 32, 49, 72, 13, null);
select zloz_zamowienie(1, 2, 42, 16, 72, 64, null);
select zloz_zamowienie(1, 4, 1, 47, 72, 84, null);
select zloz_zamowienie(1, 2, 37, 14, 72, 12, null);
select zloz_zamowienie(2, 1, 25, 23, 72, 74, null);
select zloz_zamowienie(2, 2, 38, 40, 72, 3, null);
select zloz_zamowienie(2, 4, 44, 21, 72, 60, null);
select zloz_zamowienie(2, 3, 39, 22, 72, 97, null);
select zloz_zamowienie(2, 2, 50, 34, 72, 89, null);
select zloz_zamowienie(1, 1, 15, 6, 72, 67, null);
select zloz_zamowienie(1, 1, 44, 11, 72, 50, null);
select zloz_zamowienie(1, 3, 28, 50, 72, 90, null);
select zloz_zamowienie(1, 4, 5, 25, 72, 22, null);
select zloz_zamowienie(1, 4, 7, 39, 72, 11, null);
select zloz_zamowienie(2, 3, 33, 18, 72, 18, null);
select zloz_zamowienie(1, 4, 45, 23, 72, 58, null);
select zloz_zamowienie(1, 1, 24, 46, 72, 1, null);
select zloz_zamowienie(1, 3, 47, 18, 72, 82, null);
select zloz_zamowienie(1, 3, 14, 18, 72, 10, null);
select zloz_zamowienie(1, 1, 21, 8, 73, 66, null);
select zloz_zamowienie(2, 4, 21, 10, 73, 58, null);
select zloz_zamowienie(1, 2, 17, 35, 73, 8, null);
select zloz_zamowienie(1, 4, 17, 50, 73, 17, null);
select zloz_zamowienie(2, 3, 31, 2, 73, 97, null);
select zloz_zamowienie(2, 4, 13, 19, 73, 36, null);
select zloz_zamowienie(1, 1, 33, 28, 73, 9, null);
select zloz_zamowienie(1, 2, 12, 40, 73, 60, null);
select zloz_zamowienie(1, 3, 24, 19, 73, 4, null);
select zloz_zamowienie(2, 4, 15, 28, 73, 83, null);
select zloz_zamowienie(2, 3, 22, 6, 73, 12, null);
select zloz_zamowienie(1, 1, 47, 40, 73, 85, null);
select zloz_zamowienie(2, 3, 23, 20, 73, 91, null);
select zloz_zamowienie(2, 4, 6, 35, 73, 87, null);
select zloz_zamowienie(2, 4, 23, 2, 73, 95, null);
select zloz_zamowienie(1, 3, 22, 3, 73, 33, null);
select zloz_zamowienie(1, 3, 50, 28, 73, 16, null);
select zloz_zamowienie(2, 2, 40, 15, 73, 99, null);
select zloz_zamowienie(1, 4, 16, 23, 73, 95, null);
select zloz_zamowienie(1, 4, 36, 23, 73, 18, null);
select zloz_zamowienie(1, 2, 37, 46, 74, 59, null);
select zloz_zamowienie(1, 2, 27, 16, 74, 70, null);
select zloz_zamowienie(2, 3, 25, 18, 74, 10, null);
select zloz_zamowienie(2, 3, 48, 40, 74, 86, null);
select zloz_zamowienie(1, 4, 41, 28, 74, 48, null);
select zloz_zamowienie(1, 2, 5, 43, 74, 14, null);
select zloz_zamowienie(2, 4, 3, 35, 74, 30, null);
select zloz_zamowienie(1, 4, 9, 27, 74, 46, null);
select zloz_zamowienie(2, 1, 18, 14, 74, 38, null);
select zloz_zamowienie(2, 3, 30, 5, 74, 61, null);
select zloz_zamowienie(1, 2, 8, 19, 74, 17, null);
select zloz_zamowienie(2, 1, 29, 21, 74, 98, null);
select zloz_zamowienie(1, 4, 45, 49, 74, 76, null);
select zloz_zamowienie(2, 1, 40, 17, 74, 86, null);
select zloz_zamowienie(1, 3, 37, 20, 74, 2, null);
select zloz_zamowienie(2, 2, 34, 6, 74, 79, null);
select zloz_zamowienie(2, 1, 22, 30, 74, 68, null);
select zloz_zamowienie(1, 4, 26, 41, 74, 50, null);
select zloz_zamowienie(1, 3, 3, 46, 74, 89, null);
select zloz_zamowienie(1, 4, 14, 18, 74, 68, null);
select zloz_zamowienie(1, 4, 26, 4, 75, 27, null);
select zloz_zamowienie(2, 4, 30, 4, 75, 62, null);
select zloz_zamowienie(2, 2, 37, 14, 75, 89, null);
select zloz_zamowienie(1, 4, 48, 16, 75, 93, null);
select zloz_zamowienie(2, 4, 9, 19, 75, 5, null);
select zloz_zamowienie(1, 4, 34, 22, 75, 74, null);
select zloz_zamowienie(2, 3, 32, 15, 75, 27, null);
select zloz_zamowienie(2, 4, 37, 47, 75, 9, null);
select zloz_zamowienie(2, 2, 45, 24, 75, 11, null);
select zloz_zamowienie(2, 2, 28, 9, 75, 16, null);
select zloz_zamowienie(1, 1, 13, 39, 75, 99, null);
select zloz_zamowienie(2, 1, 9, 20, 75, 70, null);
select zloz_zamowienie(1, 1, 8, 2, 75, 1, null);
select zloz_zamowienie(1, 1, 48, 25, 75, 26, null);
select zloz_zamowienie(2, 2, 50, 23, 75, 16, null);
select zloz_zamowienie(1, 2, 45, 18, 75, 43, null);
select zloz_zamowienie(1, 3, 41, 43, 75, 5, null);
select zloz_zamowienie(1, 1, 7, 47, 75, 27, null);
select zloz_zamowienie(1, 3, 22, 31, 75, 43, null);
select zloz_zamowienie(1, 2, 5, 40, 75, 78, null);
select zloz_zamowienie(2, 3, 28, 24, 76, 98, null);
select zloz_zamowienie(1, 3, 1, 46, 76, 53, null);
select zloz_zamowienie(2, 4, 27, 44, 76, 1, null);
select zloz_zamowienie(2, 2, 50, 22, 76, 73, null);
select zloz_zamowienie(2, 1, 20, 11, 76, 92, null);
select zloz_zamowienie(1, 4, 38, 23, 76, 71, null);
select zloz_zamowienie(2, 4, 14, 33, 76, 64, null);
select zloz_zamowienie(1, 3, 48, 12, 76, 38, null);
select zloz_zamowienie(2, 2, 46, 16, 76, 14, null);
select zloz_zamowienie(1, 4, 1, 18, 76, 52, null);
select zloz_zamowienie(2, 3, 17, 16, 76, 23, null);
select zloz_zamowienie(1, 4, 7, 42, 76, 8, null);
select zloz_zamowienie(2, 3, 35, 15, 76, 100, null);
select zloz_zamowienie(2, 3, 15, 6, 76, 56, null);
select zloz_zamowienie(2, 3, 33, 19, 76, 32, null);
select zloz_zamowienie(2, 1, 3, 42, 76, 58, null);
select zloz_zamowienie(1, 4, 44, 24, 76, 25, null);
select zloz_zamowienie(2, 4, 15, 3, 76, 96, null);
select zloz_zamowienie(1, 1, 14, 10, 76, 91, null);
select zloz_zamowienie(1, 2, 4, 27, 76, 73, null);
select zloz_zamowienie(2, 3, 14, 30, 77, 36, null);
select zloz_zamowienie(2, 1, 28, 10, 77, 61, null);
select zloz_zamowienie(2, 4, 38, 37, 77, 46, null);
select zloz_zamowienie(1, 3, 22, 44, 77, 2, null);
select zloz_zamowienie(2, 3, 21, 50, 77, 12, null);
select zloz_zamowienie(2, 2, 45, 24, 77, 5, null);
select zloz_zamowienie(2, 2, 37, 16, 77, 86, null);
select zloz_zamowienie(1, 2, 46, 7, 77, 36, null);
select zloz_zamowienie(1, 3, 20, 22, 77, 44, null);
select zloz_zamowienie(2, 2, 34, 37, 77, 59, null);
select zloz_zamowienie(1, 4, 40, 11, 77, 3, null);
select zloz_zamowienie(2, 4, 27, 39, 77, 36, null);
select zloz_zamowienie(1, 4, 29, 44, 77, 69, null);
select zloz_zamowienie(2, 1, 43, 39, 77, 12, null);
select zloz_zamowienie(2, 3, 36, 27, 77, 71, null);
select zloz_zamowienie(1, 1, 41, 24, 77, 49, null);
select zloz_zamowienie(2, 4, 50, 33, 77, 82, null);
select zloz_zamowienie(1, 3, 19, 48, 77, 1, null);
select zloz_zamowienie(2, 4, 44, 19, 77, 96, null);
select zloz_zamowienie(1, 2, 4, 25, 77, 92, null);
select zloz_zamowienie(1, 4, 22, 11, 78, 11, null);
select zloz_zamowienie(2, 3, 24, 23, 78, 57, null);
select zloz_zamowienie(2, 2, 6, 31, 78, 68, null);
select zloz_zamowienie(1, 3, 35, 48, 78, 3, null);
select zloz_zamowienie(2, 4, 22, 19, 78, 36, null);
select zloz_zamowienie(2, 1, 26, 21, 78, 30, null);
select zloz_zamowienie(2, 3, 22, 20, 78, 91, null);
select zloz_zamowienie(1, 4, 7, 22, 78, 94, null);
select zloz_zamowienie(1, 2, 1, 21, 78, 60, null);
select zloz_zamowienie(1, 3, 34, 43, 78, 27, null);
select zloz_zamowienie(1, 3, 13, 15, 78, 42, null);
select zloz_zamowienie(2, 3, 47, 41, 78, 73, null);
select zloz_zamowienie(2, 3, 45, 24, 78, 4, null);
select zloz_zamowienie(1, 2, 23, 46, 78, 45, null);
select zloz_zamowienie(2, 2, 24, 41, 78, 40, null);
select zloz_zamowienie(1, 3, 27, 7, 78, 62, null);
select zloz_zamowienie(2, 3, 4, 44, 78, 24, null);
select zloz_zamowienie(2, 3, 42, 48, 78, 51, null);
select zloz_zamowienie(1, 3, 5, 24, 78, 60, null);
select zloz_zamowienie(2, 1, 20, 3, 78, 61, null);
select zloz_zamowienie(2, 2, 13, 1, 79, 85, null);
select zloz_zamowienie(1, 4, 22, 19, 79, 3, null);
select zloz_zamowienie(2, 2, 21, 10, 79, 43, null);
select zloz_zamowienie(2, 1, 13, 24, 79, 22, null);
select zloz_zamowienie(1, 1, 40, 11, 79, 76, null);
select zloz_zamowienie(2, 1, 43, 49, 79, 44, null);
select zloz_zamowienie(1, 1, 9, 38, 79, 43, null);
select zloz_zamowienie(2, 2, 28, 42, 79, 8, null);
select zloz_zamowienie(1, 3, 47, 44, 79, 84, null);
select zloz_zamowienie(2, 1, 10, 4, 79, 50, null);
select zloz_zamowienie(2, 4, 47, 24, 79, 32, null);
select zloz_zamowienie(2, 1, 12, 1, 79, 17, null);
select zloz_zamowienie(1, 1, 20, 43, 79, 56, null);
select zloz_zamowienie(1, 4, 9, 13, 79, 52, null);
select zloz_zamowienie(1, 2, 28, 32, 79, 89, null);
select zloz_zamowienie(2, 1, 30, 39, 79, 15, null);
select zloz_zamowienie(1, 1, 38, 33, 79, 99, null);
select zloz_zamowienie(2, 1, 45, 30, 79, 13, null);
select zloz_zamowienie(1, 2, 34, 41, 79, 19, null);
select zloz_zamowienie(2, 4, 27, 32, 79, 60, null);
select zloz_zamowienie(2, 3, 27, 19, 80, 61, null);
select zloz_zamowienie(1, 2, 38, 31, 80, 19, null);
select zloz_zamowienie(2, 2, 39, 32, 80, 61, null);
select zloz_zamowienie(1, 2, 36, 46, 80, 65, null);
select zloz_zamowienie(1, 2, 41, 12, 80, 52, null);
select zloz_zamowienie(1, 2, 25, 23, 80, 47, null);
select zloz_zamowienie(1, 4, 32, 8, 80, 96, null);
select zloz_zamowienie(1, 2, 14, 9, 80, 46, null);
select zloz_zamowienie(1, 3, 31, 23, 80, 54, null);
select zloz_zamowienie(1, 4, 6, 36, 80, 49, null);
select zloz_zamowienie(1, 4, 25, 24, 80, 72, null);
select zloz_zamowienie(1, 2, 36, 48, 80, 40, null);
select zloz_zamowienie(2, 2, 47, 8, 80, 98, null);
select zloz_zamowienie(1, 1, 35, 6, 80, 100, null);
select zloz_zamowienie(2, 1, 50, 23, 80, 8, null);
select zloz_zamowienie(1, 3, 40, 36, 80, 26, null);
select zloz_zamowienie(1, 3, 13, 35, 80, 16, null);
select zloz_zamowienie(2, 3, 18, 14, 80, 30, null);
select zloz_zamowienie(1, 4, 26, 4, 80, 93, null);
select zloz_zamowienie(2, 4, 38, 1, 80, 62, null);
select zloz_zamowienie(2, 1, 44, 39, 81, 86, null);
select zloz_zamowienie(2, 1, 17, 11, 81, 2, null);
select zloz_zamowienie(1, 2, 14, 6, 81, 8, null);
select zloz_zamowienie(2, 2, 50, 49, 81, 79, null);
select zloz_zamowienie(2, 3, 19, 25, 81, 18, null);
select zloz_zamowienie(1, 3, 42, 10, 81, 43, null);
select zloz_zamowienie(1, 1, 38, 44, 81, 1, null);
select zloz_zamowienie(1, 1, 17, 34, 81, 11, null);
select zloz_zamowienie(1, 4, 40, 42, 81, 38, null);
select zloz_zamowienie(2, 2, 30, 6, 81, 7, null);
select zloz_zamowienie(2, 3, 1, 10, 81, 95, null);
select zloz_zamowienie(1, 4, 41, 25, 81, 91, null);
select zloz_zamowienie(2, 4, 9, 28, 81, 40, null);
select zloz_zamowienie(2, 4, 31, 16, 81, 77, null);
select zloz_zamowienie(2, 2, 50, 21, 81, 89, null);
select zloz_zamowienie(1, 2, 42, 48, 81, 80, null);
select zloz_zamowienie(2, 3, 31, 11, 81, 99, null);
select zloz_zamowienie(1, 4, 21, 48, 81, 67, null);
select zloz_zamowienie(2, 2, 49, 47, 81, 75, null);
select zloz_zamowienie(2, 2, 20, 15, 81, 7, null);
select zloz_zamowienie(2, 1, 9, 3, 82, 24, null);
select zloz_zamowienie(2, 3, 41, 11, 82, 77, null);
select zloz_zamowienie(1, 4, 32, 36, 82, 7, null);
select zloz_zamowienie(2, 2, 5, 9, 82, 80, null);
select zloz_zamowienie(1, 1, 29, 13, 82, 37, null);
select zloz_zamowienie(2, 1, 31, 20, 82, 11, null);
select zloz_zamowienie(2, 1, 42, 15, 82, 33, null);
select zloz_zamowienie(1, 2, 30, 27, 82, 10, null);
select zloz_zamowienie(2, 2, 34, 12, 82, 54, null);
select zloz_zamowienie(1, 2, 12, 35, 82, 95, null);
select zloz_zamowienie(1, 1, 4, 8, 82, 47, null);
select zloz_zamowienie(1, 1, 29, 7, 82, 20, null);
select zloz_zamowienie(2, 1, 29, 30, 82, 7, null);
select zloz_zamowienie(2, 3, 8, 39, 82, 80, null);
select zloz_zamowienie(1, 1, 25, 23, 82, 4, null);
select zloz_zamowienie(2, 4, 24, 27, 82, 31, null);
select zloz_zamowienie(2, 4, 5, 11, 82, 8, null);
select zloz_zamowienie(1, 1, 36, 39, 82, 15, null);
select zloz_zamowienie(1, 4, 30, 22, 82, 21, null);
select zloz_zamowienie(1, 3, 39, 28, 82, 27, null);
select zloz_zamowienie(2, 2, 44, 17, 83, 68, null);
select zloz_zamowienie(2, 3, 39, 42, 83, 82, null);
select zloz_zamowienie(2, 4, 15, 14, 83, 79, null);
select zloz_zamowienie(2, 3, 19, 26, 83, 7, null);
select zloz_zamowienie(1, 3, 2, 19, 83, 20, null);
select zloz_zamowienie(2, 3, 50, 47, 83, 80, null);
select zloz_zamowienie(1, 1, 38, 14, 83, 4, null);
select zloz_zamowienie(2, 4, 21, 19, 83, 5, null);
select zloz_zamowienie(1, 3, 31, 50, 83, 25, null);
select zloz_zamowienie(2, 3, 30, 3, 83, 75, null);
select zloz_zamowienie(2, 3, 1, 50, 83, 55, null);
select zloz_zamowienie(1, 2, 4, 2, 83, 44, null);
select zloz_zamowienie(1, 2, 22, 25, 83, 47, null);
select zloz_zamowienie(2, 3, 23, 39, 83, 28, null);
select zloz_zamowienie(2, 2, 25, 29, 83, 42, null);
select zloz_zamowienie(2, 3, 31, 20, 83, 3, null);
select zloz_zamowienie(2, 2, 30, 17, 83, 46, null);
select zloz_zamowienie(2, 1, 5, 38, 83, 58, null);
select zloz_zamowienie(1, 1, 28, 12, 83, 25, null);
select zloz_zamowienie(1, 4, 14, 30, 83, 44, null);
select zloz_zamowienie(2, 4, 14, 30, 84, 14, null);
select zloz_zamowienie(2, 3, 19, 17, 84, 9, null);
select zloz_zamowienie(2, 2, 43, 35, 84, 14, null);
select zloz_zamowienie(1, 1, 50, 35, 84, 67, null);
select zloz_zamowienie(2, 1, 45, 4, 84, 40, null);
select zloz_zamowienie(2, 4, 37, 10, 84, 80, null);
select zloz_zamowienie(1, 3, 12, 41, 84, 2, null);
select zloz_zamowienie(2, 1, 10, 35, 84, 61, null);
select zloz_zamowienie(2, 2, 10, 6, 84, 19, null);
select zloz_zamowienie(2, 4, 48, 26, 84, 21, null);
select zloz_zamowienie(1, 4, 11, 36, 84, 50, null);
select zloz_zamowienie(1, 2, 30, 15, 84, 67, null);
select zloz_zamowienie(2, 1, 22, 41, 84, 97, null);
select zloz_zamowienie(2, 3, 22, 28, 84, 56, null);
select zloz_zamowienie(2, 3, 22, 47, 84, 100, null);
select zloz_zamowienie(2, 2, 11, 37, 84, 63, null);
select zloz_zamowienie(2, 1, 22, 2, 84, 73, null);
select zloz_zamowienie(1, 4, 12, 34, 84, 45, null);
select zloz_zamowienie(1, 4, 12, 44, 84, 93, null);
select zloz_zamowienie(1, 3, 40, 44, 84, 87, null);
select zloz_zamowienie(2, 3, 8, 43, 85, 93, null);
select zloz_zamowienie(2, 2, 18, 23, 85, 8, null);
select zloz_zamowienie(2, 1, 2, 22, 85, 51, null);
select zloz_zamowienie(1, 1, 11, 22, 85, 77, null);
select zloz_zamowienie(1, 1, 17, 26, 85, 12, null);
select zloz_zamowienie(1, 4, 46, 50, 85, 15, null);
select zloz_zamowienie(1, 3, 33, 42, 85, 7, null);
select zloz_zamowienie(1, 1, 32, 13, 85, 29, null);
select zloz_zamowienie(1, 4, 2, 18, 85, 18, null);
select zloz_zamowienie(2, 2, 30, 32, 85, 75, null);
select zloz_zamowienie(2, 2, 50, 47, 85, 98, null);
select zloz_zamowienie(1, 3, 22, 1, 85, 25, null);
select zloz_zamowienie(1, 4, 40, 2, 85, 69, null);
select zloz_zamowienie(2, 2, 43, 34, 85, 21, null);
select zloz_zamowienie(2, 1, 19, 4, 85, 37, null);
select zloz_zamowienie(1, 4, 23, 42, 85, 54, null);
select zloz_zamowienie(2, 1, 3, 2, 85, 84, null);
select zloz_zamowienie(2, 3, 47, 42, 85, 22, null);
select zloz_zamowienie(1, 1, 6, 31, 85, 67, null);
select zloz_zamowienie(2, 2, 23, 4, 85, 90, null);
select zloz_zamowienie(1, 3, 25, 2, 86, 18, null);
select zloz_zamowienie(1, 4, 46, 15, 86, 13, null);
select zloz_zamowienie(2, 3, 8, 46, 86, 84, null);
select zloz_zamowienie(1, 4, 50, 30, 86, 37, null);
select zloz_zamowienie(1, 1, 30, 45, 86, 69, null);
select zloz_zamowienie(1, 4, 44, 43, 86, 82, null);
select zloz_zamowienie(2, 4, 27, 39, 86, 3, null);
select zloz_zamowienie(2, 4, 10, 24, 86, 30, null);
select zloz_zamowienie(2, 1, 15, 19, 86, 58, null);
select zloz_zamowienie(1, 1, 17, 47, 86, 63, null);
select zloz_zamowienie(1, 3, 2, 14, 86, 99, null);
select zloz_zamowienie(1, 2, 35, 5, 86, 47, null);
select zloz_zamowienie(1, 2, 2, 15, 86, 5, null);
select zloz_zamowienie(2, 4, 50, 13, 86, 16, null);
select zloz_zamowienie(1, 1, 50, 14, 86, 14, null);
select zloz_zamowienie(1, 1, 43, 26, 86, 96, null);
select zloz_zamowienie(1, 3, 1, 23, 86, 16, null);
select zloz_zamowienie(1, 2, 21, 15, 86, 24, null);
select zloz_zamowienie(2, 4, 18, 16, 86, 38, null);
select zloz_zamowienie(2, 2, 48, 15, 86, 9, null);
select zloz_zamowienie(1, 3, 13, 46, 87, 47, null);
select zloz_zamowienie(1, 4, 48, 16, 87, 97, null);
select zloz_zamowienie(2, 4, 20, 6, 87, 39, null);
select zloz_zamowienie(2, 4, 44, 16, 87, 91, null);
select zloz_zamowienie(2, 4, 8, 26, 87, 13, null);
select zloz_zamowienie(2, 2, 37, 11, 87, 31, null);
select zloz_zamowienie(1, 3, 1, 50, 87, 16, null);
select zloz_zamowienie(1, 1, 19, 25, 87, 88, null);
select zloz_zamowienie(1, 4, 26, 44, 87, 56, null);
select zloz_zamowienie(2, 1, 6, 11, 87, 92, null);
select zloz_zamowienie(1, 2, 36, 27, 87, 95, null);
select zloz_zamowienie(1, 4, 5, 37, 87, 8, null);
select zloz_zamowienie(1, 1, 40, 17, 87, 50, null);
select zloz_zamowienie(1, 4, 13, 20, 87, 99, null);
select zloz_zamowienie(1, 4, 11, 37, 87, 79, null);
select zloz_zamowienie(2, 1, 19, 28, 87, 33, null);
select zloz_zamowienie(1, 2, 27, 12, 87, 94, null);
select zloz_zamowienie(1, 3, 40, 10, 87, 59, null);
select zloz_zamowienie(1, 4, 23, 25, 87, 81, null);
select zloz_zamowienie(1, 4, 3, 45, 87, 79, null);
select zloz_zamowienie(2, 4, 40, 5, 88, 62, null);
select zloz_zamowienie(1, 3, 25, 6, 88, 26, null);
select zloz_zamowienie(2, 4, 42, 25, 88, 13, null);
select zloz_zamowienie(1, 3, 45, 20, 88, 39, null);
select zloz_zamowienie(1, 3, 48, 11, 88, 40, null);
select zloz_zamowienie(2, 1, 39, 30, 88, 72, null);
select zloz_zamowienie(2, 3, 28, 24, 88, 55, null);
select zloz_zamowienie(2, 2, 9, 6, 88, 65, null);
select zloz_zamowienie(2, 4, 33, 3, 88, 12, null);
select zloz_zamowienie(1, 1, 37, 5, 88, 98, null);
select zloz_zamowienie(2, 4, 36, 14, 88, 42, null);
select zloz_zamowienie(2, 3, 29, 37, 88, 61, null);
select zloz_zamowienie(1, 3, 17, 8, 88, 83, null);
select zloz_zamowienie(1, 1, 31, 19, 88, 4, null);
select zloz_zamowienie(2, 2, 17, 6, 88, 75, null);
select zloz_zamowienie(2, 3, 21, 2, 88, 62, null);
select zloz_zamowienie(1, 1, 41, 38, 88, 25, null);
select zloz_zamowienie(1, 4, 12, 39, 88, 56, null);
select zloz_zamowienie(2, 2, 33, 32, 88, 74, null);
select zloz_zamowienie(2, 2, 19, 31, 88, 64, null);
select zloz_zamowienie(2, 2, 41, 5, 89, 76, null);
select zloz_zamowienie(2, 1, 23, 32, 89, 40, null);
select zloz_zamowienie(2, 2, 7, 22, 89, 94, null);
select zloz_zamowienie(2, 2, 26, 5, 89, 41, null);
select zloz_zamowienie(1, 2, 7, 24, 89, 35, null);
select zloz_zamowienie(1, 2, 19, 11, 89, 49, null);
select zloz_zamowienie(2, 2, 15, 3, 89, 73, null);
select zloz_zamowienie(2, 1, 7, 30, 89, 36, null);
select zloz_zamowienie(1, 1, 19, 10, 89, 73, null);
select zloz_zamowienie(1, 3, 9, 26, 89, 23, null);
select zloz_zamowienie(1, 4, 37, 40, 89, 34, null);
select zloz_zamowienie(2, 3, 42, 39, 89, 12, null);
select zloz_zamowienie(2, 4, 50, 11, 89, 47, null);
select zloz_zamowienie(1, 4, 11, 39, 89, 91, null);
select zloz_zamowienie(2, 2, 34, 12, 89, 47, null);
select zloz_zamowienie(1, 4, 11, 38, 89, 9, null);
select zloz_zamowienie(1, 1, 26, 29, 89, 28, null);
select zloz_zamowienie(2, 3, 1, 19, 89, 98, null);
select zloz_zamowienie(1, 4, 36, 30, 89, 82, null);
select zloz_zamowienie(2, 3, 1, 35, 89, 51, null);
select zloz_zamowienie(2, 4, 38, 45, 90, 1, null);
select zloz_zamowienie(1, 2, 19, 10, 90, 94, null);
select zloz_zamowienie(1, 1, 32, 42, 90, 39, null);
select zloz_zamowienie(1, 2, 31, 21, 90, 57, null);
select zloz_zamowienie(2, 1, 5, 47, 90, 44, null);
select zloz_zamowienie(1, 3, 50, 4, 90, 58, null);
select zloz_zamowienie(1, 2, 19, 16, 90, 30, null);
select zloz_zamowienie(1, 4, 40, 22, 90, 28, null);
select zloz_zamowienie(2, 2, 24, 15, 90, 91, null);
select zloz_zamowienie(1, 2, 48, 13, 90, 33, null);
select zloz_zamowienie(2, 1, 32, 41, 90, 55, null);
select zloz_zamowienie(1, 1, 20, 18, 90, 38, null);
select zloz_zamowienie(2, 2, 26, 15, 90, 10, null);
select zloz_zamowienie(2, 4, 23, 42, 90, 32, null);
select zloz_zamowienie(1, 3, 28, 38, 90, 41, null);
select zloz_zamowienie(2, 3, 48, 32, 90, 58, null);
select zloz_zamowienie(1, 3, 14, 12, 90, 28, null);
select zloz_zamowienie(2, 2, 5, 38, 90, 31, null);
select zloz_zamowienie(2, 2, 49, 39, 90, 79, null);
select zloz_zamowienie(1, 2, 3, 50, 90, 79, null);
select zloz_zamowienie(1, 2, 41, 33, 91, 87, null);
select zloz_zamowienie(1, 3, 9, 26, 91, 45, null);
select zloz_zamowienie(2, 2, 50, 42, 91, 84, null);
select zloz_zamowienie(2, 4, 14, 18, 91, 89, null);
select zloz_zamowienie(1, 1, 42, 30, 91, 98, null);
select zloz_zamowienie(2, 2, 39, 42, 91, 31, null);
select zloz_zamowienie(1, 4, 4, 40, 91, 43, null);
select zloz_zamowienie(1, 2, 43, 16, 91, 78, null);
select zloz_zamowienie(1, 1, 3, 42, 91, 47, null);
select zloz_zamowienie(1, 4, 22, 18, 91, 94, null);
select zloz_zamowienie(2, 4, 37, 9, 91, 81, null);
select zloz_zamowienie(1, 2, 19, 20, 91, 70, null);
select zloz_zamowienie(2, 2, 21, 14, 91, 28, null);
select zloz_zamowienie(1, 1, 41, 34, 91, 26, null);
select zloz_zamowienie(2, 1, 22, 16, 91, 45, null);
select zloz_zamowienie(1, 4, 34, 50, 91, 11, null);
select zloz_zamowienie(1, 1, 50, 23, 91, 69, null);
select zloz_zamowienie(2, 2, 2, 24, 91, 6, null);
select zloz_zamowienie(1, 3, 32, 45, 91, 47, null);
select zloz_zamowienie(1, 4, 2, 7, 91, 57, null);
select zloz_zamowienie(2, 3, 15, 14, 92, 86, null);
select zloz_zamowienie(1, 1, 23, 34, 92, 66, null);
select zloz_zamowienie(1, 4, 6, 9, 92, 76, null);
select zloz_zamowienie(1, 2, 5, 38, 92, 87, null);
select zloz_zamowienie(2, 1, 10, 34, 92, 21, null);
select zloz_zamowienie(2, 4, 37, 3, 92, 35, null);
select zloz_zamowienie(1, 2, 10, 22, 92, 78, null);
select zloz_zamowienie(1, 3, 17, 26, 92, 34, null);
select zloz_zamowienie(1, 2, 8, 1, 92, 45, null);
select zloz_zamowienie(1, 1, 26, 7, 92, 15, null);
select zloz_zamowienie(2, 1, 28, 41, 92, 84, null);
select zloz_zamowienie(1, 2, 35, 9, 92, 99, null);
select zloz_zamowienie(2, 2, 10, 5, 92, 45, null);
select zloz_zamowienie(1, 1, 30, 34, 92, 30, null);
select zloz_zamowienie(2, 3, 18, 31, 92, 63, null);
select zloz_zamowienie(1, 1, 25, 22, 92, 72, null);
select zloz_zamowienie(2, 1, 7, 17, 92, 53, null);
select zloz_zamowienie(1, 2, 6, 10, 92, 30, null);
select zloz_zamowienie(2, 1, 15, 16, 92, 87, null);
select zloz_zamowienie(2, 3, 44, 22, 92, 52, null);
select zloz_zamowienie(1, 4, 47, 48, 93, 78, null);
select zloz_zamowienie(1, 3, 46, 47, 93, 34, null);
select zloz_zamowienie(1, 4, 45, 36, 93, 64, null);
select zloz_zamowienie(2, 2, 4, 26, 93, 51, null);
select zloz_zamowienie(2, 3, 1, 33, 93, 2, null);
select zloz_zamowienie(2, 1, 22, 6, 93, 34, null);
select zloz_zamowienie(2, 4, 37, 38, 93, 91, null);
select zloz_zamowienie(1, 4, 36, 28, 93, 40, null);
select zloz_zamowienie(2, 2, 46, 8, 93, 62, null);
select zloz_zamowienie(1, 2, 40, 24, 93, 39, null);
select zloz_zamowienie(2, 1, 27, 21, 93, 90, null);
select zloz_zamowienie(1, 4, 7, 34, 93, 30, null);
select zloz_zamowienie(2, 2, 34, 42, 93, 50, null);
select zloz_zamowienie(1, 1, 35, 29, 93, 100, null);
select zloz_zamowienie(2, 1, 7, 45, 93, 84, null);
select zloz_zamowienie(1, 4, 22, 29, 93, 13, null);
select zloz_zamowienie(2, 2, 39, 15, 93, 69, null);
select zloz_zamowienie(1, 2, 21, 25, 93, 51, null);
select zloz_zamowienie(2, 1, 18, 37, 93, 23, null);
select zloz_zamowienie(2, 3, 43, 37, 93, 62, null);
select zloz_zamowienie(1, 2, 4, 23, 94, 41, null);
select zloz_zamowienie(2, 4, 25, 33, 94, 15, null);
select zloz_zamowienie(2, 2, 9, 29, 94, 24, null);
select zloz_zamowienie(2, 2, 44, 31, 94, 40, null);
select zloz_zamowienie(2, 1, 45, 49, 94, 21, null);
select zloz_zamowienie(1, 3, 14, 34, 94, 40, null);
select zloz_zamowienie(2, 3, 25, 9, 94, 35, null);
select zloz_zamowienie(1, 2, 14, 27, 94, 35, null);
select zloz_zamowienie(2, 2, 30, 23, 94, 62, null);
select zloz_zamowienie(2, 1, 15, 10, 94, 18, null);
select zloz_zamowienie(1, 1, 32, 1, 94, 7, null);
select zloz_zamowienie(2, 3, 24, 46, 94, 68, null);
select zloz_zamowienie(1, 1, 22, 44, 94, 17, null);
select zloz_zamowienie(1, 3, 48, 47, 94, 81, null);
select zloz_zamowienie(1, 4, 42, 25, 94, 70, null);
select zloz_zamowienie(2, 3, 27, 48, 94, 12, null);
select zloz_zamowienie(1, 1, 2, 8, 94, 44, null);
select zloz_zamowienie(2, 2, 14, 12, 94, 66, null);
select zloz_zamowienie(1, 4, 17, 43, 94, 91, null);
select zloz_zamowienie(2, 1, 12, 35, 94, 14, null);
select zloz_zamowienie(2, 2, 10, 44, 95, 85, null);
select zloz_zamowienie(2, 3, 38, 35, 95, 1, null);
select zloz_zamowienie(2, 1, 35, 14, 95, 2, null);
select zloz_zamowienie(2, 3, 43, 1, 95, 37, null);
select zloz_zamowienie(2, 4, 41, 9, 95, 87, null);
select zloz_zamowienie(2, 3, 49, 39, 95, 50, null);
select zloz_zamowienie(2, 1, 7, 1, 95, 58, null);
select zloz_zamowienie(1, 2, 19, 50, 95, 98, null);
select zloz_zamowienie(2, 2, 35, 3, 95, 24, null);
select zloz_zamowienie(1, 3, 46, 18, 95, 5, null);
select zloz_zamowienie(2, 2, 8, 49, 95, 29, null);
select zloz_zamowienie(1, 4, 4, 50, 95, 68, null);
select zloz_zamowienie(1, 4, 29, 3, 95, 68, null);
select zloz_zamowienie(1, 1, 8, 3, 95, 21, null);
select zloz_zamowienie(1, 2, 2, 45, 95, 19, null);
select zloz_zamowienie(1, 2, 44, 47, 95, 71, null);
select zloz_zamowienie(1, 4, 26, 1, 95, 84, null);
select zloz_zamowienie(1, 3, 50, 41, 95, 62, null);
select zloz_zamowienie(1, 4, 38, 13, 95, 4, null);
select zloz_zamowienie(2, 2, 21, 30, 95, 88, null);
select zloz_zamowienie(1, 3, 43, 34, 96, 11, null);
select zloz_zamowienie(2, 1, 47, 5, 96, 23, null);
select zloz_zamowienie(1, 1, 10, 47, 96, 100, null);
select zloz_zamowienie(1, 2, 10, 16, 96, 59, null);
select zloz_zamowienie(1, 1, 35, 45, 96, 51, null);
select zloz_zamowienie(2, 3, 36, 10, 96, 11, null);
select zloz_zamowienie(1, 3, 14, 49, 96, 53, null);
select zloz_zamowienie(2, 2, 7, 1, 96, 35, null);
select zloz_zamowienie(1, 2, 25, 21, 96, 46, null);
select zloz_zamowienie(1, 4, 24, 9, 96, 36, null);
select zloz_zamowienie(2, 4, 28, 23, 96, 69, null);
select zloz_zamowienie(2, 2, 23, 21, 96, 53, null);
select zloz_zamowienie(2, 3, 30, 18, 96, 76, null);
select zloz_zamowienie(1, 3, 17, 7, 96, 62, null);
select zloz_zamowienie(2, 3, 32, 37, 96, 27, null);
select zloz_zamowienie(1, 4, 42, 2, 96, 94, null);
select zloz_zamowienie(1, 1, 7, 34, 96, 32, null);
select zloz_zamowienie(1, 4, 19, 24, 96, 16, null);
select zloz_zamowienie(2, 3, 16, 20, 96, 1, null);
select zloz_zamowienie(1, 1, 45, 9, 96, 11, null);
select zloz_zamowienie(1, 1, 6, 17, 97, 79, null);
select zloz_zamowienie(1, 1, 12, 23, 97, 67, null);
select zloz_zamowienie(1, 1, 30, 5, 97, 29, null);
select zloz_zamowienie(2, 3, 1, 38, 97, 55, null);
select zloz_zamowienie(1, 2, 38, 33, 97, 43, null);
select zloz_zamowienie(2, 1, 6, 49, 97, 20, null);
select zloz_zamowienie(1, 1, 48, 3, 97, 15, null);
select zloz_zamowienie(1, 4, 37, 43, 97, 68, null);
select zloz_zamowienie(2, 2, 30, 44, 97, 91, null);
select zloz_zamowienie(2, 3, 20, 37, 97, 36, null);
select zloz_zamowienie(2, 4, 21, 6, 97, 24, null);
select zloz_zamowienie(1, 1, 24, 41, 97, 66, null);
select zloz_zamowienie(1, 4, 29, 12, 97, 55, null);
select zloz_zamowienie(2, 2, 18, 28, 97, 33, null);
select zloz_zamowienie(1, 4, 18, 44, 97, 30, null);
select zloz_zamowienie(2, 3, 20, 31, 97, 50, null);
select zloz_zamowienie(2, 3, 6, 49, 97, 96, null);
select zloz_zamowienie(2, 4, 5, 18, 97, 99, null);
select zloz_zamowienie(1, 2, 45, 21, 97, 19, null);
select zloz_zamowienie(1, 3, 17, 30, 97, 42, null);
select zloz_zamowienie(1, 4, 20, 18, 98, 67, null);
select zloz_zamowienie(1, 2, 49, 22, 98, 96, null);
select zloz_zamowienie(2, 3, 41, 44, 98, 21, null);
select zloz_zamowienie(1, 2, 5, 10, 98, 26, null);
select zloz_zamowienie(1, 3, 8, 31, 98, 49, null);
select zloz_zamowienie(1, 3, 18, 27, 98, 45, null);
select zloz_zamowienie(1, 3, 41, 33, 98, 72, null);
select zloz_zamowienie(1, 2, 49, 42, 98, 28, null);
select zloz_zamowienie(2, 3, 26, 6, 98, 94, null);
select zloz_zamowienie(1, 2, 35, 31, 98, 57, null);
select zloz_zamowienie(1, 4, 19, 15, 98, 5, null);
select zloz_zamowienie(2, 4, 40, 14, 98, 26, null);
select zloz_zamowienie(1, 4, 2, 44, 98, 24, null);
select zloz_zamowienie(1, 1, 32, 23, 98, 27, null);
select zloz_zamowienie(2, 1, 28, 37, 98, 38, null);
select zloz_zamowienie(1, 4, 19, 21, 98, 70, null);
select zloz_zamowienie(2, 1, 21, 27, 98, 15, null);
select zloz_zamowienie(1, 3, 32, 5, 98, 24, null);
select zloz_zamowienie(2, 1, 8, 49, 98, 80, null);
select zloz_zamowienie(1, 2, 40, 27, 98, 100, null);
select zloz_zamowienie(1, 2, 37, 10, 99, 1, null);
select zloz_zamowienie(1, 4, 33, 8, 99, 76, null);
select zloz_zamowienie(2, 2, 18, 10, 99, 21, null);
select zloz_zamowienie(2, 1, 48, 38, 99, 53, null);
select zloz_zamowienie(2, 1, 48, 33, 99, 29, null);
select zloz_zamowienie(2, 4, 18, 19, 99, 6, null);
select zloz_zamowienie(2, 4, 32, 31, 99, 42, null);
select zloz_zamowienie(2, 3, 4, 27, 99, 24, null);
select zloz_zamowienie(2, 4, 23, 29, 99, 38, null);
select zloz_zamowienie(2, 4, 17, 43, 99, 35, null);
select zloz_zamowienie(2, 2, 10, 16, 99, 81, null);
select zloz_zamowienie(1, 4, 29, 39, 99, 73, null);
select zloz_zamowienie(1, 1, 4, 38, 99, 51, null);
select zloz_zamowienie(1, 1, 2, 32, 99, 17, null);
select zloz_zamowienie(1, 1, 28, 30, 99, 62, null);
select zloz_zamowienie(2, 4, 36, 40, 99, 64, null);
select zloz_zamowienie(2, 1, 45, 16, 99, 20, null);
select zloz_zamowienie(1, 1, 1, 31, 99, 77, null);
select zloz_zamowienie(1, 1, 50, 14, 99, 24, null);
select zloz_zamowienie(2, 1, 35, 20, 99, 90, null);
select zloz_zamowienie(2, 3, 19, 21, 100, 47, null);
select zloz_zamowienie(2, 1, 22, 29, 100, 29, null);
select zloz_zamowienie(1, 3, 15, 45, 100, 20, null);
select zloz_zamowienie(2, 4, 14, 26, 100, 28, null);
select zloz_zamowienie(2, 1, 17, 7, 100, 31, null);
select zloz_zamowienie(1, 3, 36, 12, 100, 86, null);
select zloz_zamowienie(2, 3, 13, 27, 100, 47, null);
select zloz_zamowienie(2, 2, 16, 12, 100, 76, null);
select zloz_zamowienie(2, 4, 12, 25, 100, 47, null);
select zloz_zamowienie(1, 2, 24, 29, 100, 43, null);
select zloz_zamowienie(2, 2, 27, 7, 100, 38, null);
select zloz_zamowienie(1, 2, 44, 1, 100, 28, null);
select zloz_zamowienie(1, 1, 23, 46, 100, 65, null);
select zloz_zamowienie(1, 4, 11, 1, 100, 21, null);
select zloz_zamowienie(1, 2, 47, 32, 100, 66, null);
select zloz_zamowienie(2, 1, 26, 37, 100, 61, null);
select zloz_zamowienie(2, 1, 3, 38, 100, 58, null);
select zloz_zamowienie(1, 4, 4, 50, 100, 52, null);
select zloz_zamowienie(1, 4, 21, 24, 100, 20, null);
select zloz_zamowienie(2, 2, 23, 14, 100, 71, null);

