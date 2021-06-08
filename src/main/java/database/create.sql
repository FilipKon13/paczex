
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
(1, 2, 8),
(1, 3, 27),
(1, 4, 14),
(2, 1, 13),
(2, 2, 11),
(2, 3, 65),
(2, 4, 64),
(3, 1, 21),
(3, 2, 28),
(3, 3, 38),
(3, 4, 93),
(4, 1, 52),
(4, 2, 40),
(4, 3, 38),
(4, 4, 54),
(5, 1, 78),
(5, 2, 36),
(5, 3, 64),
(5, 4, 49),
(6, 1, 96),
(6, 2, 73),
(6, 3, 61),
(6, 4, 6),
(7, 1, 90),
(7, 2, 2),
(7, 3, 36),
(7, 4, 14),
(8, 1, 52),
(8, 2, 76),
(8, 3, 46),
(8, 4, 40),
(9, 1, 80),
(9, 2, 15),
(9, 3, 97),
(9, 4, 4),
(10, 1, 42),
(10, 2, 4),
(10, 3, 39),
(10, 4, 7),
(11, 1, 93),
(11, 2, 81),
(11, 3, 59),
(11, 4, 65),
(12, 1, 51),
(12, 2, 79),
(12, 3, 37),
(12, 4, 90),
(13, 1, 24),
(13, 2, 4),
(13, 3, 9),
(13, 4, 55),
(14, 1, 51),
(14, 2, 27),
(14, 3, 5),
(14, 4, 0),
(15, 1, 12),
(15, 2, 61),
(15, 3, 49),
(15, 4, 48),
(16, 1, 20),
(16, 2, 14),
(16, 3, 75),
(16, 4, 67),
(17, 1, 13),
(17, 2, 97),
(17, 3, 36),
(17, 4, 78),
(18, 1, 5),
(18, 2, 87),
(18, 3, 56),
(18, 4, 4),
(19, 1, 96),
(19, 2, 62),
(19, 3, 91),
(19, 4, 97),
(20, 1, 61),
(20, 2, 59),
(20, 3, 82),
(20, 4, 56),
(21, 1, 28),
(21, 2, 6),
(21, 3, 83),
(21, 4, 15),
(22, 1, 4),
(22, 2, 12),
(22, 3, 67),
(22, 4, 85),
(23, 1, 69),
(23, 2, 12),
(23, 3, 7),
(23, 4, 67),
(24, 1, 41),
(24, 2, 78),
(24, 3, 43),
(24, 4, 2),
(25, 1, 83),
(25, 2, 32),
(25, 3, 18),
(25, 4, 6),
(26, 1, 41),
(26, 2, 31),
(26, 3, 32),
(26, 4, 72),
(27, 1, 54),
(27, 2, 14),
(27, 3, 85),
(27, 4, 47),
(28, 1, 19),
(28, 2, 54),
(28, 3, 92),
(28, 4, 8),
(29, 1, 81),
(29, 2, 81),
(29, 3, 66),
(29, 4, 67),
(30, 1, 5),
(30, 2, 74),
(30, 3, 21),
(30, 4, 33),
(31, 1, 46),
(31, 2, 99),
(31, 3, 18),
(31, 4, 27),
(32, 1, 94),
(32, 2, 97),
(32, 3, 87),
(32, 4, 83),
(33, 1, 87),
(33, 2, 29),
(33, 3, 62),
(33, 4, 91),
(34, 1, 45),
(34, 2, 85),
(34, 3, 57),
(34, 4, 36),
(35, 1, 27),
(35, 2, 21),
(35, 3, 77),
(35, 4, 81),
(36, 1, 36),
(36, 2, 36),
(36, 3, 59),
(36, 4, 37),
(37, 1, 29),
(37, 2, 46),
(37, 3, 22),
(37, 4, 91),
(38, 1, 27),
(38, 2, 11),
(38, 3, 21),
(38, 4, 56),
(39, 1, 61),
(39, 2, 80),
(39, 3, 60),
(39, 4, 95),
(40, 1, 9),
(40, 2, 44),
(40, 3, 2),
(40, 4, 43),
(41, 1, 56),
(41, 2, 1),
(41, 3, 73),
(41, 4, 81),
(42, 1, 78),
(42, 2, 1),
(42, 3, 65),
(42, 4, 75),
(43, 1, 88),
(43, 2, 77),
(43, 3, 24),
(43, 4, 55),
(44, 1, 33),
(44, 2, 91),
(44, 3, 95),
(44, 4, 7),
(45, 1, 71),
(45, 2, 53),
(45, 3, 77),
(45, 4, 22),
(46, 1, 96),
(46, 2, 27),
(46, 3, 16),
(46, 4, 47),
(47, 1, 49),
(47, 2, 75),
(47, 3, 99),
(47, 4, 49),
(48, 1, 71),
(48, 2, 60),
(48, 3, 86),
(48, 4, 26),
(49, 1, 44),
(49, 2, 34),
(49, 3, 7),
(49, 4, 42),
(50, 1, 91),
(50, 2, 50),
(50, 3, 2),
(50, 4, 94),

insert into rabaty_stale_klienci values
(1,10);

select zloz_zamowienie(2, 2, 24, 2, 1, 66, null);
select zloz_zamowienie(2, 4, 7, 12, 1, 71, null);
select zloz_zamowienie(2, 3, 49, 44, 1, 9, null);
select zloz_zamowienie(2, 4, 38, 27, 1, 3, null);
select zloz_zamowienie(1, 2, 36, 11, 1, 19, null);
select zloz_zamowienie(2, 4, 10, 21, 1, 52, null);
select zloz_zamowienie(2, 1, 40, 25, 1, 37, null);
select zloz_zamowienie(2, 3, 23, 28, 1, 60, null);
select zloz_zamowienie(1, 3, 9, 43, 1, 9, null);
select zloz_zamowienie(2, 3, 26, 37, 1, 43, null);
select zloz_zamowienie(2, 2, 3, 25, 1, 67, null);
select zloz_zamowienie(1, 4, 29, 10, 1, 69, null);
select zloz_zamowienie(2, 1, 10, 46, 1, 12, null);
select zloz_zamowienie(1, 3, 32, 29, 1, 53, null);
select zloz_zamowienie(1, 1, 3, 43, 1, 18, null);
select zloz_zamowienie(2, 3, 38, 20, 1, 20, null);
select zloz_zamowienie(1, 4, 3, 24, 1, 28, null);
select zloz_zamowienie(2, 3, 34, 49, 1, 26, null);
select zloz_zamowienie(1, 1, 24, 44, 1, 49, null);
select zloz_zamowienie(1, 3, 5, 9, 1, 14, null);
select zloz_zamowienie(2, 2, 30, 29, 2, 23, null);
select zloz_zamowienie(1, 3, 1, 48, 2, 50, null);
select zloz_zamowienie(2, 2, 37, 31, 2, 65, null);
select zloz_zamowienie(2, 3, 10, 42, 2, 62, null);
select zloz_zamowienie(1, 3, 23, 36, 2, 81, null);
select zloz_zamowienie(2, 2, 23, 47, 2, 23, null);
select zloz_zamowienie(2, 4, 23, 37, 2, 42, null);
select zloz_zamowienie(1, 3, 31, 47, 2, 98, null);
select zloz_zamowienie(2, 2, 28, 25, 2, 33, null);
select zloz_zamowienie(2, 3, 30, 46, 2, 63, null);
select zloz_zamowienie(1, 3, 20, 27, 2, 58, null);
select zloz_zamowienie(2, 4, 40, 7, 2, 56, null);
select zloz_zamowienie(2, 3, 5, 18, 2, 99, null);
select zloz_zamowienie(2, 4, 11, 22, 2, 68, null);
select zloz_zamowienie(1, 1, 42, 27, 2, 50, null);
select zloz_zamowienie(2, 2, 21, 4, 2, 60, null);
select zloz_zamowienie(1, 3, 4, 47, 2, 56, null);
select zloz_zamowienie(1, 4, 43, 22, 2, 81, null);
select zloz_zamowienie(1, 1, 31, 36, 2, 92, null);
select zloz_zamowienie(1, 4, 12, 36, 2, 80, null);
select zloz_zamowienie(2, 2, 2, 6, 3, 27, null);
select zloz_zamowienie(2, 4, 41, 19, 3, 2, null);
select zloz_zamowienie(1, 4, 33, 43, 3, 46, null);
select zloz_zamowienie(1, 4, 45, 16, 3, 87, null);
select zloz_zamowienie(1, 4, 34, 37, 3, 30, null);
select zloz_zamowienie(1, 1, 45, 12, 3, 74, null);
select zloz_zamowienie(1, 1, 32, 6, 3, 5, null);
select zloz_zamowienie(2, 1, 37, 17, 3, 73, null);
select zloz_zamowienie(1, 4, 25, 13, 3, 65, null);
select zloz_zamowienie(2, 1, 17, 11, 3, 16, null);
select zloz_zamowienie(1, 1, 36, 25, 3, 63, null);
select zloz_zamowienie(1, 2, 27, 10, 3, 98, null);
select zloz_zamowienie(2, 4, 38, 3, 3, 76, null);
select zloz_zamowienie(1, 3, 24, 31, 3, 20, null);
select zloz_zamowienie(1, 1, 11, 7, 3, 30, null);
select zloz_zamowienie(1, 3, 7, 1, 3, 10, null);
select zloz_zamowienie(1, 4, 21, 22, 3, 52, null);
select zloz_zamowienie(1, 4, 32, 4, 3, 57, null);
select zloz_zamowienie(2, 4, 37, 19, 3, 29, null);
select zloz_zamowienie(2, 4, 26, 50, 3, 80, null);
select zloz_zamowienie(2, 4, 13, 40, 4, 97, null);
select zloz_zamowienie(1, 3, 5, 6, 4, 55, null);
select zloz_zamowienie(1, 2, 17, 1, 4, 76, null);
select zloz_zamowienie(2, 2, 3, 21, 4, 12, null);
select zloz_zamowienie(2, 1, 1, 41, 4, 39, null);
select zloz_zamowienie(1, 1, 40, 26, 4, 62, null);
select zloz_zamowienie(1, 3, 21, 35, 4, 84, null);
select zloz_zamowienie(2, 2, 33, 5, 4, 9, null);
select zloz_zamowienie(2, 4, 17, 24, 4, 75, null);
select zloz_zamowienie(2, 4, 8, 50, 4, 47, null);
select zloz_zamowienie(2, 1, 50, 10, 4, 9, null);
select zloz_zamowienie(2, 1, 46, 16, 4, 5, null);
select zloz_zamowienie(1, 1, 41, 6, 4, 81, null);
select zloz_zamowienie(1, 3, 47, 15, 4, 69, null);
select zloz_zamowienie(2, 3, 35, 27, 4, 22, null);
select zloz_zamowienie(1, 3, 9, 11, 4, 68, null);
select zloz_zamowienie(2, 3, 48, 35, 4, 57, null);
select zloz_zamowienie(2, 2, 3, 10, 4, 80, null);
select zloz_zamowienie(2, 1, 19, 2, 4, 82, null);
select zloz_zamowienie(2, 4, 28, 4, 4, 58, null);
select zloz_zamowienie(1, 2, 15, 40, 5, 3, null);
select zloz_zamowienie(1, 4, 39, 26, 5, 97, null);
select zloz_zamowienie(1, 2, 10, 35, 5, 23, null);
select zloz_zamowienie(1, 1, 27, 49, 5, 55, null);
select zloz_zamowienie(1, 4, 28, 20, 5, 6, null);
select zloz_zamowienie(2, 4, 9, 12, 5, 41, null);
select zloz_zamowienie(1, 4, 35, 48, 5, 58, null);
select zloz_zamowienie(2, 1, 28, 46, 5, 47, null);
select zloz_zamowienie(2, 4, 47, 39, 5, 52, null);
select zloz_zamowienie(1, 2, 2, 41, 5, 41, null);
select zloz_zamowienie(2, 2, 4, 18, 5, 97, null);
select zloz_zamowienie(1, 2, 11, 5, 5, 69, null);
select zloz_zamowienie(1, 2, 41, 24, 5, 70, null);
select zloz_zamowienie(1, 4, 14, 21, 5, 48, null);
select zloz_zamowienie(1, 3, 46, 22, 5, 42, null);
select zloz_zamowienie(1, 3, 48, 38, 5, 13, null);
select zloz_zamowienie(1, 4, 13, 24, 5, 73, null);
select zloz_zamowienie(1, 1, 46, 14, 5, 56, null);
select zloz_zamowienie(2, 1, 45, 43, 5, 84, null);
select zloz_zamowienie(1, 4, 28, 31, 5, 38, null);
select zloz_zamowienie(1, 2, 23, 19, 6, 64, null);
select zloz_zamowienie(1, 1, 13, 17, 6, 32, null);
select zloz_zamowienie(1, 1, 27, 48, 6, 41, null);
select zloz_zamowienie(2, 3, 16, 48, 6, 55, null);
select zloz_zamowienie(2, 3, 7, 35, 6, 81, null);
select zloz_zamowienie(1, 2, 15, 23, 6, 54, null);
select zloz_zamowienie(2, 3, 40, 31, 6, 38, null);
select zloz_zamowienie(1, 4, 13, 30, 6, 66, null);
select zloz_zamowienie(1, 3, 37, 19, 6, 1, null);
select zloz_zamowienie(2, 3, 37, 26, 6, 67, null);
select zloz_zamowienie(1, 1, 49, 2, 6, 4, null);
select zloz_zamowienie(2, 1, 19, 20, 6, 27, null);
select zloz_zamowienie(1, 4, 1, 17, 6, 72, null);
select zloz_zamowienie(1, 4, 10, 25, 6, 25, null);
select zloz_zamowienie(1, 1, 37, 49, 6, 60, null);
select zloz_zamowienie(2, 2, 21, 47, 6, 72, null);
select zloz_zamowienie(2, 2, 13, 2, 6, 81, null);
select zloz_zamowienie(2, 2, 7, 24, 6, 77, null);
select zloz_zamowienie(2, 3, 8, 24, 6, 56, null);
select zloz_zamowienie(2, 2, 9, 41, 6, 19, null);
select zloz_zamowienie(1, 1, 16, 4, 7, 93, null);
select zloz_zamowienie(2, 3, 29, 10, 7, 79, null);
select zloz_zamowienie(2, 3, 24, 12, 7, 52, null);
select zloz_zamowienie(1, 1, 31, 43, 7, 15, null);
select zloz_zamowienie(1, 2, 19, 14, 7, 80, null);
select zloz_zamowienie(1, 1, 49, 35, 7, 70, null);
select zloz_zamowienie(2, 2, 31, 2, 7, 2, null);
select zloz_zamowienie(1, 3, 20, 18, 7, 81, null);
select zloz_zamowienie(1, 1, 31, 4, 7, 100, null);
select zloz_zamowienie(2, 3, 48, 42, 7, 70, null);
select zloz_zamowienie(1, 2, 26, 42, 7, 62, null);
select zloz_zamowienie(1, 2, 33, 24, 7, 84, null);
select zloz_zamowienie(2, 1, 41, 48, 7, 79, null);
select zloz_zamowienie(1, 2, 43, 35, 7, 31, null);
select zloz_zamowienie(2, 3, 4, 48, 7, 95, null);
select zloz_zamowienie(2, 3, 8, 31, 7, 35, null);
select zloz_zamowienie(2, 3, 29, 20, 7, 28, null);
select zloz_zamowienie(1, 4, 47, 40, 7, 26, null);
select zloz_zamowienie(2, 2, 39, 26, 7, 11, null);
select zloz_zamowienie(2, 1, 31, 25, 7, 40, null);
select zloz_zamowienie(1, 1, 46, 8, 8, 88, null);
select zloz_zamowienie(1, 2, 16, 17, 8, 28, null);
select zloz_zamowienie(1, 4, 7, 16, 8, 95, null);
select zloz_zamowienie(2, 4, 18, 37, 8, 100, null);
select zloz_zamowienie(2, 1, 49, 4, 8, 66, null);
select zloz_zamowienie(2, 3, 42, 49, 8, 59, null);
select zloz_zamowienie(1, 2, 48, 23, 8, 91, null);
select zloz_zamowienie(1, 3, 31, 9, 8, 62, null);
select zloz_zamowienie(2, 2, 14, 8, 8, 7, null);
select zloz_zamowienie(2, 4, 28, 30, 8, 40, null);
select zloz_zamowienie(2, 4, 32, 29, 8, 69, null);
select zloz_zamowienie(2, 1, 34, 11, 8, 49, null);
select zloz_zamowienie(1, 3, 9, 49, 8, 64, null);
select zloz_zamowienie(2, 4, 17, 37, 8, 25, null);
select zloz_zamowienie(1, 1, 25, 12, 8, 14, null);
select zloz_zamowienie(1, 4, 26, 29, 8, 14, null);
select zloz_zamowienie(1, 1, 41, 50, 8, 57, null);
select zloz_zamowienie(1, 1, 13, 31, 8, 15, null);
select zloz_zamowienie(2, 4, 26, 21, 8, 15, null);
select zloz_zamowienie(1, 3, 43, 18, 8, 81, null);
select zloz_zamowienie(1, 3, 36, 32, 9, 98, null);
select zloz_zamowienie(2, 4, 38, 35, 9, 7, null);
select zloz_zamowienie(2, 1, 35, 20, 9, 93, null);
select zloz_zamowienie(2, 4, 37, 36, 9, 62, null);
select zloz_zamowienie(1, 1, 49, 18, 9, 11, null);
select zloz_zamowienie(1, 2, 13, 31, 9, 40, null);
select zloz_zamowienie(2, 4, 11, 50, 9, 26, null);
select zloz_zamowienie(2, 1, 26, 24, 9, 54, null);
select zloz_zamowienie(2, 2, 6, 28, 9, 85, null);
select zloz_zamowienie(2, 2, 50, 8, 9, 83, null);
select zloz_zamowienie(2, 3, 49, 26, 9, 24, null);
select zloz_zamowienie(1, 3, 7, 29, 9, 47, null);
select zloz_zamowienie(1, 3, 42, 16, 9, 18, null);
select zloz_zamowienie(2, 3, 40, 18, 9, 73, null);
select zloz_zamowienie(1, 4, 8, 45, 9, 51, null);
select zloz_zamowienie(1, 4, 23, 27, 9, 65, null);
select zloz_zamowienie(2, 1, 12, 9, 9, 2, null);
select zloz_zamowienie(1, 1, 3, 29, 9, 32, null);
select zloz_zamowienie(2, 4, 12, 50, 9, 41, null);
select zloz_zamowienie(1, 1, 11, 5, 9, 19, null);
select zloz_zamowienie(1, 4, 41, 21, 10, 57, null);
select zloz_zamowienie(2, 1, 16, 9, 10, 92, null);
select zloz_zamowienie(1, 2, 46, 14, 10, 69, null);
select zloz_zamowienie(1, 1, 31, 1, 10, 14, null);
select zloz_zamowienie(2, 3, 19, 41, 10, 23, null);
select zloz_zamowienie(2, 3, 44, 4, 10, 76, null);
select zloz_zamowienie(1, 4, 10, 25, 10, 80, null);
select zloz_zamowienie(1, 1, 40, 22, 10, 60, null);
select zloz_zamowienie(1, 1, 16, 25, 10, 85, null);
select zloz_zamowienie(1, 4, 15, 10, 10, 66, null);
select zloz_zamowienie(1, 2, 32, 28, 10, 87, null);
select zloz_zamowienie(2, 1, 30, 23, 10, 61, null);
select zloz_zamowienie(1, 2, 39, 43, 10, 76, null);
select zloz_zamowienie(1, 3, 30, 19, 10, 42, null);
select zloz_zamowienie(1, 3, 50, 45, 10, 47, null);
select zloz_zamowienie(2, 3, 46, 23, 10, 79, null);
select zloz_zamowienie(2, 2, 6, 47, 10, 83, null);
select zloz_zamowienie(1, 1, 5, 12, 10, 5, null);
select zloz_zamowienie(1, 3, 42, 17, 10, 44, null);
select zloz_zamowienie(2, 2, 43, 34, 10, 44, null);
select zloz_zamowienie(1, 1, 46, 45, 11, 93, null);
select zloz_zamowienie(1, 2, 35, 6, 11, 25, null);
select zloz_zamowienie(2, 2, 20, 41, 11, 39, null);
select zloz_zamowienie(2, 4, 38, 47, 11, 33, null);
select zloz_zamowienie(2, 3, 2, 48, 11, 20, null);
select zloz_zamowienie(1, 3, 12, 25, 11, 36, null);
select zloz_zamowienie(2, 3, 4, 26, 11, 69, null);
select zloz_zamowienie(1, 2, 23, 35, 11, 20, null);
select zloz_zamowienie(2, 1, 29, 27, 11, 65, null);
select zloz_zamowienie(1, 1, 48, 41, 11, 17, null);
select zloz_zamowienie(2, 1, 48, 21, 11, 74, null);
select zloz_zamowienie(2, 3, 28, 36, 11, 38, null);
select zloz_zamowienie(2, 2, 21, 48, 11, 88, null);
select zloz_zamowienie(2, 4, 43, 41, 11, 92, null);
select zloz_zamowienie(1, 1, 35, 4, 11, 26, null);
select zloz_zamowienie(2, 3, 8, 23, 11, 32, null);
select zloz_zamowienie(1, 2, 4, 13, 11, 67, null);
select zloz_zamowienie(1, 4, 28, 23, 11, 74, null);
select zloz_zamowienie(1, 3, 38, 27, 11, 98, null);
select zloz_zamowienie(1, 3, 11, 2, 11, 39, null);
select zloz_zamowienie(1, 4, 31, 35, 12, 54, null);
select zloz_zamowienie(2, 2, 10, 50, 12, 84, null);
select zloz_zamowienie(2, 4, 24, 20, 12, 43, null);
select zloz_zamowienie(1, 4, 16, 44, 12, 57, null);
select zloz_zamowienie(2, 2, 35, 11, 12, 70, null);
select zloz_zamowienie(1, 1, 1, 14, 12, 8, null);
select zloz_zamowienie(2, 3, 13, 24, 12, 22, null);
select zloz_zamowienie(2, 4, 14, 10, 12, 70, null);
select zloz_zamowienie(2, 1, 33, 31, 12, 28, null);
select zloz_zamowienie(1, 3, 36, 47, 12, 94, null);
select zloz_zamowienie(1, 4, 39, 4, 12, 79, null);
select zloz_zamowienie(2, 2, 37, 23, 12, 14, null);
select zloz_zamowienie(1, 2, 37, 31, 12, 31, null);
select zloz_zamowienie(1, 3, 15, 19, 12, 48, null);
select zloz_zamowienie(1, 2, 33, 36, 12, 45, null);
select zloz_zamowienie(1, 2, 15, 47, 12, 49, null);
select zloz_zamowienie(1, 1, 40, 10, 12, 91, null);
select zloz_zamowienie(2, 1, 39, 45, 12, 50, null);
select zloz_zamowienie(1, 4, 38, 35, 12, 24, null);
select zloz_zamowienie(2, 1, 37, 27, 12, 53, null);
select zloz_zamowienie(1, 2, 16, 27, 13, 37, null);
select zloz_zamowienie(1, 1, 10, 4, 13, 43, null);
select zloz_zamowienie(2, 3, 26, 14, 13, 27, null);
select zloz_zamowienie(2, 4, 45, 30, 13, 86, null);
select zloz_zamowienie(2, 1, 39, 41, 13, 32, null);
select zloz_zamowienie(2, 4, 30, 15, 13, 12, null);
select zloz_zamowienie(2, 3, 24, 43, 13, 96, null);
select zloz_zamowienie(2, 4, 25, 20, 13, 92, null);
select zloz_zamowienie(1, 1, 43, 16, 13, 67, null);
select zloz_zamowienie(2, 3, 29, 48, 13, 84, null);
select zloz_zamowienie(2, 2, 20, 49, 13, 91, null);
select zloz_zamowienie(1, 2, 21, 40, 13, 70, null);
select zloz_zamowienie(1, 2, 42, 31, 13, 45, null);
select zloz_zamowienie(2, 1, 16, 29, 13, 37, null);
select zloz_zamowienie(1, 4, 35, 50, 13, 81, null);
select zloz_zamowienie(2, 3, 19, 47, 13, 27, null);
select zloz_zamowienie(2, 3, 24, 16, 13, 1, null);
select zloz_zamowienie(1, 2, 6, 46, 13, 94, null);
select zloz_zamowienie(2, 4, 40, 43, 13, 9, null);
select zloz_zamowienie(2, 4, 42, 29, 13, 71, null);
select zloz_zamowienie(2, 3, 49, 21, 14, 57, null);
select zloz_zamowienie(2, 4, 12, 17, 14, 56, null);
select zloz_zamowienie(2, 4, 14, 25, 14, 83, null);
select zloz_zamowienie(1, 3, 37, 6, 14, 71, null);
select zloz_zamowienie(1, 2, 29, 40, 14, 6, null);
select zloz_zamowienie(2, 4, 2, 37, 14, 15, null);
select zloz_zamowienie(2, 2, 13, 2, 14, 53, null);
select zloz_zamowienie(1, 3, 13, 28, 14, 31, null);
select zloz_zamowienie(1, 3, 36, 3, 14, 46, null);
select zloz_zamowienie(2, 1, 48, 7, 14, 40, null);
select zloz_zamowienie(1, 4, 39, 44, 14, 99, null);
select zloz_zamowienie(1, 1, 19, 48, 14, 52, null);
select zloz_zamowienie(2, 1, 7, 30, 14, 92, null);
select zloz_zamowienie(1, 2, 25, 12, 14, 18, null);
select zloz_zamowienie(1, 1, 4, 34, 14, 43, null);
select zloz_zamowienie(2, 3, 26, 15, 14, 33, null);
select zloz_zamowienie(2, 4, 31, 13, 14, 41, null);
select zloz_zamowienie(1, 3, 29, 3, 14, 67, null);
select zloz_zamowienie(2, 3, 45, 13, 14, 17, null);
select zloz_zamowienie(1, 4, 15, 26, 14, 93, null);
select zloz_zamowienie(2, 4, 47, 12, 15, 69, null);
select zloz_zamowienie(1, 2, 23, 21, 15, 88, null);
select zloz_zamowienie(2, 2, 12, 47, 15, 23, null);
select zloz_zamowienie(2, 4, 2, 43, 15, 88, null);
select zloz_zamowienie(1, 3, 22, 4, 15, 61, null);
select zloz_zamowienie(2, 2, 12, 41, 15, 50, null);
select zloz_zamowienie(2, 1, 37, 15, 15, 27, null);
select zloz_zamowienie(1, 2, 32, 15, 15, 29, null);
select zloz_zamowienie(1, 3, 44, 23, 15, 59, null);
select zloz_zamowienie(2, 4, 29, 12, 15, 41, null);
select zloz_zamowienie(1, 3, 31, 49, 15, 22, null);
select zloz_zamowienie(2, 4, 3, 38, 15, 86, null);
select zloz_zamowienie(2, 2, 35, 45, 15, 10, null);
select zloz_zamowienie(1, 1, 43, 19, 15, 80, null);
select zloz_zamowienie(2, 3, 12, 18, 15, 68, null);
select zloz_zamowienie(1, 2, 8, 50, 15, 76, null);
select zloz_zamowienie(2, 4, 6, 28, 15, 47, null);
select zloz_zamowienie(1, 3, 29, 3, 15, 47, null);
select zloz_zamowienie(1, 3, 47, 13, 15, 16, null);
select zloz_zamowienie(1, 2, 25, 50, 15, 6, null);
select zloz_zamowienie(1, 1, 3, 40, 16, 79, null);
select zloz_zamowienie(2, 3, 24, 30, 16, 94, null);
select zloz_zamowienie(2, 1, 29, 16, 16, 4, null);
select zloz_zamowienie(1, 3, 12, 16, 16, 53, null);
select zloz_zamowienie(1, 3, 20, 17, 16, 54, null);
select zloz_zamowienie(2, 4, 14, 50, 16, 83, null);
select zloz_zamowienie(2, 1, 24, 13, 16, 50, null);
select zloz_zamowienie(1, 1, 26, 49, 16, 66, null);
select zloz_zamowienie(2, 1, 16, 14, 16, 72, null);
select zloz_zamowienie(1, 3, 27, 34, 16, 53, null);
select zloz_zamowienie(2, 1, 9, 29, 16, 5, null);
select zloz_zamowienie(2, 2, 24, 42, 16, 43, null);
select zloz_zamowienie(1, 2, 27, 11, 16, 5, null);
select zloz_zamowienie(1, 4, 47, 24, 16, 78, null);
select zloz_zamowienie(1, 2, 48, 23, 16, 5, null);
select zloz_zamowienie(2, 2, 25, 5, 16, 76, null);
select zloz_zamowienie(1, 2, 27, 16, 16, 1, null);
select zloz_zamowienie(1, 2, 3, 40, 16, 68, null);
select zloz_zamowienie(1, 1, 40, 27, 16, 19, null);
select zloz_zamowienie(1, 1, 27, 11, 16, 21, null);
select zloz_zamowienie(1, 1, 40, 27, 17, 98, null);
select zloz_zamowienie(2, 2, 36, 7, 17, 100, null);
select zloz_zamowienie(2, 4, 8, 14, 17, 5, null);
select zloz_zamowienie(1, 4, 20, 33, 17, 31, null);
select zloz_zamowienie(2, 4, 3, 2, 17, 39, null);
select zloz_zamowienie(2, 1, 19, 41, 17, 9, null);
select zloz_zamowienie(2, 4, 23, 7, 17, 61, null);
select zloz_zamowienie(2, 1, 11, 23, 17, 57, null);
select zloz_zamowienie(2, 3, 12, 17, 17, 33, null);
select zloz_zamowienie(2, 3, 46, 42, 17, 10, null);
select zloz_zamowienie(2, 2, 5, 6, 17, 7, null);
select zloz_zamowienie(1, 2, 4, 1, 17, 20, null);
select zloz_zamowienie(1, 3, 37, 15, 17, 28, null);
select zloz_zamowienie(1, 4, 33, 13, 17, 45, null);
select zloz_zamowienie(1, 3, 26, 18, 17, 39, null);
select zloz_zamowienie(1, 3, 38, 8, 17, 35, null);
select zloz_zamowienie(2, 3, 36, 37, 17, 46, null);
select zloz_zamowienie(2, 4, 40, 10, 17, 94, null);
select zloz_zamowienie(2, 3, 50, 37, 17, 5, null);
select zloz_zamowienie(2, 4, 11, 21, 17, 55, null);
select zloz_zamowienie(1, 1, 20, 7, 18, 89, null);
select zloz_zamowienie(2, 3, 9, 18, 18, 32, null);
select zloz_zamowienie(1, 4, 18, 30, 18, 86, null);
select zloz_zamowienie(1, 2, 38, 12, 18, 98, null);
select zloz_zamowienie(1, 2, 45, 13, 18, 95, null);
select zloz_zamowienie(1, 4, 45, 50, 18, 78, null);
select zloz_zamowienie(1, 2, 49, 11, 18, 22, null);
select zloz_zamowienie(1, 2, 49, 43, 18, 42, null);
select zloz_zamowienie(2, 2, 27, 21, 18, 12, null);
select zloz_zamowienie(1, 2, 25, 10, 18, 66, null);
select zloz_zamowienie(1, 1, 15, 16, 18, 59, null);
select zloz_zamowienie(2, 1, 39, 40, 18, 71, null);
select zloz_zamowienie(1, 1, 11, 25, 18, 33, null);
select zloz_zamowienie(2, 4, 42, 12, 18, 68, null);
select zloz_zamowienie(2, 2, 35, 7, 18, 49, null);
select zloz_zamowienie(2, 4, 4, 26, 18, 85, null);
select zloz_zamowienie(1, 1, 27, 14, 18, 46, null);
select zloz_zamowienie(1, 1, 42, 4, 18, 75, null);
select zloz_zamowienie(1, 1, 4, 50, 18, 92, null);
select zloz_zamowienie(2, 4, 38, 23, 18, 58, null);
select zloz_zamowienie(1, 1, 13, 1, 19, 76, null);
select zloz_zamowienie(2, 3, 48, 7, 19, 76, null);
select zloz_zamowienie(2, 4, 42, 16, 19, 33, null);
select zloz_zamowienie(2, 2, 33, 21, 19, 8, null);
select zloz_zamowienie(2, 4, 1, 9, 19, 50, null);
select zloz_zamowienie(2, 1, 31, 34, 19, 97, null);
select zloz_zamowienie(1, 1, 41, 24, 19, 98, null);
select zloz_zamowienie(2, 4, 12, 16, 19, 33, null);
select zloz_zamowienie(2, 3, 7, 33, 19, 32, null);
select zloz_zamowienie(2, 4, 19, 24, 19, 62, null);
select zloz_zamowienie(2, 1, 32, 6, 19, 63, null);
select zloz_zamowienie(2, 4, 35, 21, 19, 82, null);
select zloz_zamowienie(1, 2, 33, 45, 19, 63, null);
select zloz_zamowienie(1, 4, 5, 48, 19, 97, null);
select zloz_zamowienie(2, 2, 45, 37, 19, 96, null);
select zloz_zamowienie(1, 1, 1, 4, 19, 9, null);
select zloz_zamowienie(1, 2, 26, 39, 19, 8, null);
select zloz_zamowienie(1, 2, 43, 31, 19, 64, null);
select zloz_zamowienie(1, 3, 22, 32, 19, 100, null);
select zloz_zamowienie(1, 1, 33, 19, 19, 53, null);
select zloz_zamowienie(1, 1, 22, 21, 20, 17, null);
select zloz_zamowienie(2, 2, 36, 43, 20, 45, null);
select zloz_zamowienie(1, 3, 41, 37, 20, 10, null);
select zloz_zamowienie(2, 1, 19, 49, 20, 88, null);
select zloz_zamowienie(1, 1, 30, 16, 20, 65, null);
select zloz_zamowienie(2, 3, 6, 22, 20, 99, null);
select zloz_zamowienie(2, 2, 22, 42, 20, 67, null);
select zloz_zamowienie(2, 3, 9, 32, 20, 38, null);
select zloz_zamowienie(1, 4, 13, 31, 20, 52, null);
select zloz_zamowienie(2, 3, 5, 33, 20, 25, null);
select zloz_zamowienie(1, 3, 23, 3, 20, 24, null);
select zloz_zamowienie(2, 4, 4, 40, 20, 94, null);
select zloz_zamowienie(2, 2, 41, 1, 20, 74, null);
select zloz_zamowienie(2, 4, 28, 9, 20, 31, null);
select zloz_zamowienie(1, 3, 43, 42, 20, 77, null);
select zloz_zamowienie(1, 4, 12, 47, 20, 88, null);
select zloz_zamowienie(2, 2, 49, 39, 20, 24, null);
select zloz_zamowienie(1, 4, 41, 34, 20, 1, null);
select zloz_zamowienie(1, 1, 15, 2, 20, 8, null);
select zloz_zamowienie(1, 2, 37, 22, 20, 58, null);
select zloz_zamowienie(2, 2, 31, 30, 21, 34, null);
select zloz_zamowienie(1, 1, 6, 47, 21, 86, null);
select zloz_zamowienie(2, 4, 13, 10, 21, 23, null);
select zloz_zamowienie(1, 4, 37, 41, 21, 8, null);
select zloz_zamowienie(2, 1, 40, 36, 21, 42, null);
select zloz_zamowienie(1, 2, 20, 42, 21, 81, null);
select zloz_zamowienie(1, 2, 10, 19, 21, 100, null);
select zloz_zamowienie(2, 4, 23, 50, 21, 65, null);
select zloz_zamowienie(2, 4, 49, 8, 21, 83, null);
select zloz_zamowienie(1, 4, 34, 30, 21, 70, null);
select zloz_zamowienie(1, 4, 38, 7, 21, 70, null);
select zloz_zamowienie(2, 3, 12, 41, 21, 100, null);
select zloz_zamowienie(1, 4, 8, 12, 21, 84, null);
select zloz_zamowienie(1, 4, 11, 27, 21, 49, null);
select zloz_zamowienie(2, 3, 6, 38, 21, 35, null);
select zloz_zamowienie(2, 1, 42, 13, 21, 70, null);
select zloz_zamowienie(1, 4, 47, 46, 21, 63, null);
select zloz_zamowienie(2, 4, 11, 1, 21, 83, null);
select zloz_zamowienie(1, 1, 33, 31, 21, 44, null);
select zloz_zamowienie(1, 4, 14, 15, 21, 49, null);
select zloz_zamowienie(1, 3, 22, 19, 22, 8, null);
select zloz_zamowienie(1, 1, 14, 2, 22, 69, null);
select zloz_zamowienie(1, 2, 34, 2, 22, 73, null);
select zloz_zamowienie(2, 2, 11, 14, 22, 43, null);
select zloz_zamowienie(1, 3, 35, 8, 22, 80, null);
select zloz_zamowienie(2, 2, 22, 33, 22, 86, null);
select zloz_zamowienie(2, 1, 30, 27, 22, 89, null);
select zloz_zamowienie(1, 2, 38, 42, 22, 45, null);
select zloz_zamowienie(1, 3, 26, 35, 22, 6, null);
select zloz_zamowienie(1, 4, 9, 42, 22, 29, null);
select zloz_zamowienie(1, 3, 35, 20, 22, 79, null);
select zloz_zamowienie(2, 1, 4, 37, 22, 2, null);
select zloz_zamowienie(1, 1, 15, 9, 22, 42, null);
select zloz_zamowienie(1, 1, 6, 25, 22, 99, null);
select zloz_zamowienie(2, 1, 40, 8, 22, 85, null);
select zloz_zamowienie(2, 1, 15, 8, 22, 95, null);
select zloz_zamowienie(2, 3, 17, 31, 22, 95, null);
select zloz_zamowienie(1, 1, 18, 3, 22, 82, null);
select zloz_zamowienie(2, 4, 37, 26, 22, 80, null);
select zloz_zamowienie(1, 1, 30, 32, 22, 39, null);
select zloz_zamowienie(1, 4, 14, 9, 23, 7, null);
select zloz_zamowienie(1, 2, 18, 15, 23, 56, null);
select zloz_zamowienie(1, 4, 22, 28, 23, 72, null);
select zloz_zamowienie(2, 2, 19, 13, 23, 38, null);
select zloz_zamowienie(1, 1, 23, 48, 23, 62, null);
select zloz_zamowienie(1, 3, 24, 13, 23, 43, null);
select zloz_zamowienie(2, 4, 29, 30, 23, 2, null);
select zloz_zamowienie(1, 4, 33, 24, 23, 43, null);
select zloz_zamowienie(2, 1, 38, 26, 23, 47, null);
select zloz_zamowienie(1, 1, 13, 15, 23, 70, null);
select zloz_zamowienie(2, 1, 39, 15, 23, 55, null);
select zloz_zamowienie(2, 2, 12, 27, 23, 81, null);
select zloz_zamowienie(1, 1, 32, 30, 23, 11, null);
select zloz_zamowienie(2, 1, 28, 27, 23, 37, null);
select zloz_zamowienie(2, 4, 33, 7, 23, 50, null);
select zloz_zamowienie(2, 1, 10, 37, 23, 29, null);
select zloz_zamowienie(1, 4, 39, 4, 23, 48, null);
select zloz_zamowienie(2, 2, 43, 29, 23, 5, null);
select zloz_zamowienie(2, 1, 24, 15, 23, 91, null);
select zloz_zamowienie(1, 3, 24, 29, 23, 66, null);
select zloz_zamowienie(1, 1, 6, 50, 24, 59, null);
select zloz_zamowienie(1, 3, 27, 28, 24, 27, null);
select zloz_zamowienie(1, 3, 1, 25, 24, 3, null);
select zloz_zamowienie(1, 1, 24, 46, 24, 55, null);
select zloz_zamowienie(1, 4, 11, 7, 24, 1, null);
select zloz_zamowienie(2, 3, 17, 31, 24, 56, null);
select zloz_zamowienie(2, 2, 37, 17, 24, 70, null);
select zloz_zamowienie(1, 2, 25, 34, 24, 18, null);
select zloz_zamowienie(1, 3, 10, 35, 24, 89, null);
select zloz_zamowienie(2, 3, 26, 37, 24, 28, null);
select zloz_zamowienie(2, 4, 3, 45, 24, 51, null);
select zloz_zamowienie(2, 1, 33, 45, 24, 53, null);
select zloz_zamowienie(2, 2, 6, 46, 24, 3, null);
select zloz_zamowienie(1, 2, 31, 9, 24, 25, null);
select zloz_zamowienie(1, 2, 48, 27, 24, 37, null);
select zloz_zamowienie(2, 4, 31, 39, 24, 43, null);
select zloz_zamowienie(2, 4, 8, 12, 24, 17, null);
select zloz_zamowienie(1, 4, 9, 16, 24, 88, null);
select zloz_zamowienie(2, 4, 8, 26, 24, 76, null);
select zloz_zamowienie(1, 4, 14, 11, 24, 23, null);
select zloz_zamowienie(1, 1, 34, 36, 25, 45, null);
select zloz_zamowienie(1, 4, 3, 8, 25, 51, null);
select zloz_zamowienie(1, 4, 48, 8, 25, 85, null);
select zloz_zamowienie(2, 3, 4, 22, 25, 39, null);
select zloz_zamowienie(2, 4, 9, 30, 25, 44, null);
select zloz_zamowienie(2, 4, 5, 27, 25, 2, null);
select zloz_zamowienie(2, 1, 1, 6, 25, 60, null);
select zloz_zamowienie(2, 4, 3, 6, 25, 68, null);
select zloz_zamowienie(1, 2, 47, 43, 25, 56, null);
select zloz_zamowienie(2, 2, 47, 5, 25, 58, null);
select zloz_zamowienie(1, 1, 14, 4, 25, 10, null);
select zloz_zamowienie(1, 3, 24, 50, 25, 16, null);
select zloz_zamowienie(1, 2, 24, 38, 25, 91, null);
select zloz_zamowienie(1, 2, 20, 13, 25, 79, null);
select zloz_zamowienie(1, 2, 38, 42, 25, 58, null);
select zloz_zamowienie(2, 2, 10, 29, 25, 39, null);
select zloz_zamowienie(1, 4, 33, 32, 25, 95, null);
select zloz_zamowienie(1, 3, 2, 12, 25, 53, null);
select zloz_zamowienie(1, 2, 45, 43, 25, 24, null);
select zloz_zamowienie(2, 4, 38, 17, 25, 26, null);
select zloz_zamowienie(2, 3, 40, 38, 26, 95, null);
select zloz_zamowienie(2, 4, 45, 47, 26, 36, null);
select zloz_zamowienie(1, 1, 32, 9, 26, 78, null);
select zloz_zamowienie(2, 4, 49, 2, 26, 27, null);
select zloz_zamowienie(1, 3, 9, 3, 26, 87, null);
select zloz_zamowienie(1, 1, 46, 42, 26, 33, null);
select zloz_zamowienie(1, 1, 21, 18, 26, 66, null);
select zloz_zamowienie(1, 1, 12, 4, 26, 39, null);
select zloz_zamowienie(2, 1, 4, 6, 26, 30, null);
select zloz_zamowienie(1, 3, 29, 25, 26, 55, null);
select zloz_zamowienie(1, 4, 42, 24, 26, 78, null);
select zloz_zamowienie(2, 3, 17, 11, 26, 75, null);
select zloz_zamowienie(2, 3, 50, 39, 26, 23, null);
select zloz_zamowienie(1, 3, 1, 36, 26, 67, null);
select zloz_zamowienie(2, 3, 40, 43, 26, 37, null);
select zloz_zamowienie(2, 2, 20, 16, 26, 99, null);
select zloz_zamowienie(2, 3, 11, 32, 26, 45, null);
select zloz_zamowienie(1, 2, 30, 23, 26, 66, null);
select zloz_zamowienie(2, 1, 10, 9, 26, 76, null);
select zloz_zamowienie(1, 3, 5, 31, 26, 76, null);
select zloz_zamowienie(1, 3, 22, 29, 27, 45, null);
select zloz_zamowienie(2, 2, 38, 35, 27, 49, null);
select zloz_zamowienie(2, 3, 12, 38, 27, 15, null);
select zloz_zamowienie(1, 3, 14, 28, 27, 45, null);
select zloz_zamowienie(1, 2, 24, 17, 27, 82, null);
select zloz_zamowienie(1, 1, 18, 23, 27, 1, null);
select zloz_zamowienie(2, 3, 21, 29, 27, 30, null);
select zloz_zamowienie(1, 3, 11, 37, 27, 46, null);
select zloz_zamowienie(2, 1, 20, 16, 27, 26, null);
select zloz_zamowienie(1, 4, 15, 43, 27, 59, null);
select zloz_zamowienie(2, 3, 3, 35, 27, 29, null);
select zloz_zamowienie(1, 4, 46, 15, 27, 92, null);
select zloz_zamowienie(1, 1, 47, 5, 27, 62, null);
select zloz_zamowienie(1, 2, 28, 20, 27, 23, null);
select zloz_zamowienie(2, 2, 42, 50, 27, 17, null);
select zloz_zamowienie(1, 2, 1, 31, 27, 48, null);
select zloz_zamowienie(1, 3, 22, 16, 27, 60, null);
select zloz_zamowienie(1, 2, 17, 12, 27, 48, null);
select zloz_zamowienie(2, 1, 45, 3, 27, 100, null);
select zloz_zamowienie(1, 2, 24, 1, 27, 65, null);
select zloz_zamowienie(2, 1, 14, 48, 28, 53, null);
select zloz_zamowienie(1, 2, 6, 31, 28, 85, null);
select zloz_zamowienie(2, 3, 14, 37, 28, 56, null);
select zloz_zamowienie(1, 4, 13, 27, 28, 25, null);
select zloz_zamowienie(2, 1, 50, 12, 28, 44, null);
select zloz_zamowienie(2, 4, 47, 46, 28, 54, null);
select zloz_zamowienie(1, 3, 17, 36, 28, 82, null);
select zloz_zamowienie(1, 3, 20, 46, 28, 33, null);
select zloz_zamowienie(2, 1, 42, 3, 28, 54, null);
select zloz_zamowienie(1, 2, 28, 32, 28, 8, null);
select zloz_zamowienie(2, 3, 35, 50, 28, 84, null);
select zloz_zamowienie(1, 2, 49, 19, 28, 21, null);
select zloz_zamowienie(1, 4, 13, 33, 28, 86, null);
select zloz_zamowienie(2, 2, 46, 8, 28, 3, null);
select zloz_zamowienie(2, 2, 31, 36, 28, 2, null);
select zloz_zamowienie(2, 2, 39, 22, 28, 54, null);
select zloz_zamowienie(1, 4, 46, 18, 28, 92, null);
select zloz_zamowienie(2, 1, 2, 8, 28, 1, null);
select zloz_zamowienie(1, 3, 50, 19, 28, 88, null);
select zloz_zamowienie(1, 4, 16, 25, 28, 36, null);
select zloz_zamowienie(2, 3, 43, 11, 29, 77, null);
select zloz_zamowienie(2, 2, 13, 31, 29, 34, null);
select zloz_zamowienie(2, 2, 25, 15, 29, 90, null);
select zloz_zamowienie(2, 1, 40, 25, 29, 73, null);
select zloz_zamowienie(1, 1, 48, 49, 29, 26, null);
select zloz_zamowienie(1, 1, 17, 20, 29, 99, null);
select zloz_zamowienie(2, 1, 47, 32, 29, 62, null);
select zloz_zamowienie(2, 3, 38, 17, 29, 93, null);
select zloz_zamowienie(1, 2, 10, 19, 29, 80, null);
select zloz_zamowienie(1, 4, 8, 48, 29, 69, null);
select zloz_zamowienie(2, 4, 48, 13, 29, 4, null);
select zloz_zamowienie(2, 1, 10, 50, 29, 33, null);
select zloz_zamowienie(1, 1, 50, 25, 29, 98, null);
select zloz_zamowienie(2, 4, 6, 17, 29, 70, null);
select zloz_zamowienie(2, 2, 15, 20, 29, 6, null);
select zloz_zamowienie(2, 2, 10, 9, 29, 64, null);
select zloz_zamowienie(2, 4, 50, 43, 29, 21, null);
select zloz_zamowienie(2, 3, 27, 8, 29, 62, null);
select zloz_zamowienie(2, 1, 27, 39, 29, 90, null);
select zloz_zamowienie(2, 2, 32, 31, 29, 2, null);
select zloz_zamowienie(2, 4, 3, 19, 30, 100, null);
select zloz_zamowienie(1, 1, 13, 34, 30, 7, null);
select zloz_zamowienie(2, 4, 47, 31, 30, 7, null);
select zloz_zamowienie(1, 1, 48, 49, 30, 69, null);
select zloz_zamowienie(1, 3, 31, 11, 30, 90, null);
select zloz_zamowienie(1, 2, 15, 17, 30, 39, null);
select zloz_zamowienie(2, 3, 22, 10, 30, 70, null);
select zloz_zamowienie(2, 3, 40, 2, 30, 32, null);
select zloz_zamowienie(2, 2, 8, 41, 30, 37, null);
select zloz_zamowienie(2, 2, 21, 49, 30, 61, null);
select zloz_zamowienie(1, 2, 19, 3, 30, 45, null);
select zloz_zamowienie(2, 3, 20, 16, 30, 84, null);
select zloz_zamowienie(1, 4, 12, 13, 30, 23, null);
select zloz_zamowienie(1, 1, 12, 13, 30, 37, null);
select zloz_zamowienie(1, 3, 39, 45, 30, 77, null);
select zloz_zamowienie(2, 1, 11, 8, 30, 56, null);
select zloz_zamowienie(1, 4, 34, 23, 30, 9, null);
select zloz_zamowienie(1, 4, 24, 28, 30, 88, null);
select zloz_zamowienie(1, 4, 18, 15, 30, 11, null);
select zloz_zamowienie(2, 2, 15, 28, 30, 73, null);
select zloz_zamowienie(2, 1, 2, 48, 31, 78, null);
select zloz_zamowienie(2, 4, 29, 5, 31, 61, null);
select zloz_zamowienie(2, 2, 10, 28, 31, 75, null);
select zloz_zamowienie(1, 4, 42, 5, 31, 49, null);
select zloz_zamowienie(1, 1, 1, 27, 31, 18, null);
select zloz_zamowienie(2, 4, 39, 22, 31, 50, null);
select zloz_zamowienie(1, 1, 32, 21, 31, 48, null);
select zloz_zamowienie(1, 4, 22, 15, 31, 100, null);
select zloz_zamowienie(1, 1, 24, 38, 31, 34, null);
select zloz_zamowienie(1, 3, 47, 33, 31, 38, null);
select zloz_zamowienie(1, 2, 35, 23, 31, 10, null);
select zloz_zamowienie(2, 3, 45, 13, 31, 32, null);
select zloz_zamowienie(1, 4, 14, 47, 31, 64, null);
select zloz_zamowienie(1, 2, 10, 37, 31, 14, null);
select zloz_zamowienie(2, 3, 19, 8, 31, 42, null);
select zloz_zamowienie(1, 4, 45, 41, 31, 19, null);
select zloz_zamowienie(2, 4, 44, 31, 31, 16, null);
select zloz_zamowienie(1, 4, 46, 25, 31, 1, null);
select zloz_zamowienie(2, 2, 36, 40, 31, 84, null);
select zloz_zamowienie(1, 2, 38, 35, 31, 85, null);
select zloz_zamowienie(1, 1, 20, 31, 32, 15, null);
select zloz_zamowienie(2, 2, 8, 46, 32, 30, null);
select zloz_zamowienie(2, 2, 6, 10, 32, 25, null);
select zloz_zamowienie(1, 1, 18, 17, 32, 41, null);
select zloz_zamowienie(2, 1, 41, 35, 32, 47, null);
select zloz_zamowienie(2, 1, 50, 35, 32, 40, null);
select zloz_zamowienie(2, 1, 22, 29, 32, 13, null);
select zloz_zamowienie(1, 2, 20, 18, 32, 47, null);
select zloz_zamowienie(2, 2, 49, 7, 32, 100, null);
select zloz_zamowienie(2, 1, 25, 32, 32, 77, null);
select zloz_zamowienie(1, 1, 21, 33, 32, 27, null);
select zloz_zamowienie(1, 1, 36, 26, 32, 85, null);
select zloz_zamowienie(1, 1, 31, 37, 32, 8, null);
select zloz_zamowienie(2, 4, 40, 7, 32, 15, null);
select zloz_zamowienie(2, 1, 34, 15, 32, 22, null);
select zloz_zamowienie(1, 3, 37, 11, 32, 35, null);
select zloz_zamowienie(1, 2, 18, 19, 32, 86, null);
select zloz_zamowienie(1, 3, 24, 27, 32, 89, null);
select zloz_zamowienie(2, 1, 19, 39, 32, 27, null);
select zloz_zamowienie(2, 1, 10, 14, 32, 58, null);
select zloz_zamowienie(2, 4, 32, 13, 33, 47, null);
select zloz_zamowienie(1, 4, 49, 47, 33, 19, null);
select zloz_zamowienie(1, 4, 27, 21, 33, 15, null);
select zloz_zamowienie(1, 2, 34, 32, 33, 13, null);
select zloz_zamowienie(1, 1, 21, 5, 33, 82, null);
select zloz_zamowienie(1, 2, 22, 46, 33, 80, null);
select zloz_zamowienie(1, 2, 15, 31, 33, 48, null);
select zloz_zamowienie(2, 1, 13, 1, 33, 21, null);
select zloz_zamowienie(2, 4, 39, 45, 33, 28, null);
select zloz_zamowienie(1, 4, 41, 37, 33, 41, null);
select zloz_zamowienie(2, 3, 30, 14, 33, 30, null);
select zloz_zamowienie(1, 4, 20, 7, 33, 89, null);
select zloz_zamowienie(1, 4, 4, 9, 33, 52, null);
select zloz_zamowienie(1, 4, 13, 45, 33, 61, null);
select zloz_zamowienie(2, 1, 49, 25, 33, 21, null);
select zloz_zamowienie(1, 4, 36, 13, 33, 40, null);
select zloz_zamowienie(2, 4, 26, 20, 33, 62, null);
select zloz_zamowienie(2, 2, 27, 5, 33, 65, null);
select zloz_zamowienie(2, 2, 48, 12, 33, 39, null);
select zloz_zamowienie(1, 2, 8, 39, 33, 84, null);
select zloz_zamowienie(2, 1, 49, 1, 34, 29, null);
select zloz_zamowienie(2, 2, 47, 43, 34, 17, null);
select zloz_zamowienie(1, 3, 20, 15, 34, 22, null);
select zloz_zamowienie(2, 3, 12, 41, 34, 53, null);
select zloz_zamowienie(1, 3, 30, 50, 34, 46, null);
select zloz_zamowienie(2, 2, 31, 27, 34, 15, null);
select zloz_zamowienie(1, 3, 40, 20, 34, 23, null);
select zloz_zamowienie(2, 3, 33, 42, 34, 83, null);
select zloz_zamowienie(2, 3, 49, 21, 34, 30, null);
select zloz_zamowienie(1, 2, 9, 23, 34, 71, null);
select zloz_zamowienie(2, 3, 42, 43, 34, 85, null);
select zloz_zamowienie(1, 1, 6, 32, 34, 76, null);
select zloz_zamowienie(2, 1, 44, 27, 34, 30, null);
select zloz_zamowienie(1, 2, 32, 16, 34, 69, null);
select zloz_zamowienie(2, 4, 14, 5, 34, 41, null);
select zloz_zamowienie(2, 2, 25, 13, 34, 86, null);
select zloz_zamowienie(2, 4, 40, 19, 34, 57, null);
select zloz_zamowienie(1, 2, 38, 31, 34, 73, null);
select zloz_zamowienie(2, 1, 25, 16, 34, 52, null);
select zloz_zamowienie(2, 1, 46, 24, 34, 56, null);
select zloz_zamowienie(1, 3, 36, 41, 35, 59, null);
select zloz_zamowienie(1, 3, 1, 50, 35, 13, null);
select zloz_zamowienie(1, 3, 20, 45, 35, 74, null);
select zloz_zamowienie(1, 3, 44, 4, 35, 53, null);
select zloz_zamowienie(2, 3, 11, 39, 35, 99, null);
select zloz_zamowienie(2, 4, 21, 20, 35, 21, null);
select zloz_zamowienie(1, 4, 33, 24, 35, 17, null);
select zloz_zamowienie(1, 1, 24, 30, 35, 90, null);
select zloz_zamowienie(1, 2, 23, 32, 35, 32, null);
select zloz_zamowienie(2, 1, 16, 20, 35, 18, null);
select zloz_zamowienie(1, 3, 26, 21, 35, 38, null);
select zloz_zamowienie(2, 1, 37, 9, 35, 8, null);
select zloz_zamowienie(2, 4, 16, 17, 35, 99, null);
select zloz_zamowienie(2, 3, 29, 46, 35, 11, null);
select zloz_zamowienie(1, 1, 40, 39, 35, 63, null);
select zloz_zamowienie(2, 3, 29, 22, 35, 26, null);
select zloz_zamowienie(2, 4, 19, 16, 35, 24, null);
select zloz_zamowienie(2, 3, 28, 35, 35, 11, null);
select zloz_zamowienie(1, 3, 11, 16, 35, 33, null);
select zloz_zamowienie(2, 2, 5, 34, 35, 51, null);
select zloz_zamowienie(2, 3, 22, 18, 36, 67, null);
select zloz_zamowienie(1, 1, 46, 8, 36, 64, null);
select zloz_zamowienie(2, 1, 4, 45, 36, 100, null);
select zloz_zamowienie(2, 2, 16, 19, 36, 94, null);
select zloz_zamowienie(2, 3, 1, 34, 36, 52, null);
select zloz_zamowienie(2, 3, 26, 12, 36, 5, null);
select zloz_zamowienie(1, 3, 37, 33, 36, 99, null);
select zloz_zamowienie(2, 1, 3, 20, 36, 35, null);
select zloz_zamowienie(2, 3, 40, 21, 36, 6, null);
select zloz_zamowienie(2, 2, 2, 39, 36, 50, null);
select zloz_zamowienie(2, 2, 20, 17, 36, 30, null);
select zloz_zamowienie(2, 3, 15, 13, 36, 1, null);
select zloz_zamowienie(1, 2, 25, 42, 36, 53, null);
select zloz_zamowienie(1, 4, 21, 41, 36, 38, null);
select zloz_zamowienie(1, 4, 12, 2, 36, 2, null);
select zloz_zamowienie(1, 1, 45, 18, 36, 64, null);
select zloz_zamowienie(1, 3, 25, 50, 36, 19, null);
select zloz_zamowienie(2, 4, 36, 28, 36, 94, null);
select zloz_zamowienie(1, 2, 23, 42, 36, 20, null);
select zloz_zamowienie(2, 1, 1, 15, 36, 10, null);
select zloz_zamowienie(2, 3, 38, 47, 37, 20, null);
select zloz_zamowienie(2, 2, 38, 9, 37, 30, null);
select zloz_zamowienie(2, 4, 41, 10, 37, 9, null);
select zloz_zamowienie(2, 3, 37, 34, 37, 19, null);
select zloz_zamowienie(1, 4, 37, 22, 37, 78, null);
select zloz_zamowienie(1, 4, 6, 50, 37, 99, null);
select zloz_zamowienie(2, 1, 37, 5, 37, 14, null);
select zloz_zamowienie(2, 1, 47, 11, 37, 67, null);
select zloz_zamowienie(1, 2, 2, 29, 37, 47, null);
select zloz_zamowienie(2, 4, 27, 15, 37, 47, null);
select zloz_zamowienie(1, 2, 36, 28, 37, 14, null);
select zloz_zamowienie(1, 4, 12, 13, 37, 19, null);
select zloz_zamowienie(2, 3, 25, 26, 37, 78, null);
select zloz_zamowienie(2, 1, 43, 39, 37, 57, null);
select zloz_zamowienie(2, 2, 47, 4, 37, 99, null);
select zloz_zamowienie(1, 4, 32, 17, 37, 65, null);
select zloz_zamowienie(1, 1, 46, 20, 37, 50, null);
select zloz_zamowienie(1, 2, 49, 35, 37, 70, null);
select zloz_zamowienie(1, 3, 21, 19, 37, 24, null);
select zloz_zamowienie(1, 2, 10, 41, 37, 67, null);
select zloz_zamowienie(1, 3, 47, 45, 38, 64, null);
select zloz_zamowienie(2, 3, 5, 16, 38, 59, null);
select zloz_zamowienie(1, 2, 22, 6, 38, 32, null);
select zloz_zamowienie(1, 3, 16, 12, 38, 94, null);
select zloz_zamowienie(1, 2, 41, 25, 38, 92, null);
select zloz_zamowienie(1, 4, 45, 36, 38, 10, null);
select zloz_zamowienie(2, 2, 33, 25, 38, 19, null);
select zloz_zamowienie(1, 1, 41, 46, 38, 18, null);
select zloz_zamowienie(1, 4, 28, 13, 38, 27, null);
select zloz_zamowienie(1, 2, 27, 33, 38, 22, null);
select zloz_zamowienie(1, 1, 26, 48, 38, 75, null);
select zloz_zamowienie(2, 4, 14, 50, 38, 63, null);
select zloz_zamowienie(1, 1, 25, 35, 38, 59, null);
select zloz_zamowienie(1, 2, 41, 28, 38, 29, null);
select zloz_zamowienie(1, 1, 22, 39, 38, 83, null);
select zloz_zamowienie(2, 3, 9, 2, 38, 27, null);
select zloz_zamowienie(2, 4, 26, 28, 38, 100, null);
select zloz_zamowienie(1, 2, 2, 35, 38, 71, null);
select zloz_zamowienie(1, 1, 11, 30, 38, 71, null);
select zloz_zamowienie(2, 1, 41, 6, 38, 64, null);
select zloz_zamowienie(2, 2, 19, 47, 39, 5, null);
select zloz_zamowienie(2, 1, 32, 42, 39, 50, null);
select zloz_zamowienie(2, 2, 45, 41, 39, 4, null);
select zloz_zamowienie(1, 3, 31, 15, 39, 83, null);
select zloz_zamowienie(2, 1, 34, 18, 39, 89, null);
select zloz_zamowienie(1, 3, 18, 38, 39, 81, null);
select zloz_zamowienie(1, 4, 18, 2, 39, 22, null);
select zloz_zamowienie(2, 1, 31, 8, 39, 30, null);
select zloz_zamowienie(1, 1, 48, 3, 39, 54, null);
select zloz_zamowienie(1, 3, 31, 46, 39, 66, null);
select zloz_zamowienie(1, 2, 44, 36, 39, 29, null);
select zloz_zamowienie(2, 4, 9, 25, 39, 11, null);
select zloz_zamowienie(2, 4, 48, 11, 39, 65, null);
select zloz_zamowienie(1, 2, 7, 50, 39, 8, null);
select zloz_zamowienie(1, 3, 36, 28, 39, 22, null);
select zloz_zamowienie(2, 2, 14, 23, 39, 22, null);
select zloz_zamowienie(1, 4, 24, 47, 39, 48, null);
select zloz_zamowienie(1, 2, 12, 24, 39, 59, null);
select zloz_zamowienie(2, 4, 48, 12, 39, 48, null);
select zloz_zamowienie(1, 3, 43, 23, 39, 3, null);
select zloz_zamowienie(2, 3, 39, 6, 40, 45, null);
select zloz_zamowienie(1, 3, 25, 34, 40, 65, null);
select zloz_zamowienie(2, 4, 30, 22, 40, 10, null);
select zloz_zamowienie(2, 4, 49, 5, 40, 90, null);
select zloz_zamowienie(2, 1, 31, 37, 40, 88, null);
select zloz_zamowienie(2, 3, 48, 3, 40, 24, null);
select zloz_zamowienie(2, 1, 13, 48, 40, 49, null);
select zloz_zamowienie(1, 3, 27, 43, 40, 47, null);
select zloz_zamowienie(2, 1, 48, 40, 40, 18, null);
select zloz_zamowienie(1, 4, 36, 29, 40, 43, null);
select zloz_zamowienie(1, 1, 23, 19, 40, 55, null);
select zloz_zamowienie(2, 3, 29, 39, 40, 35, null);
select zloz_zamowienie(2, 4, 32, 6, 40, 99, null);
select zloz_zamowienie(1, 2, 28, 21, 40, 54, null);
select zloz_zamowienie(2, 1, 2, 6, 40, 41, null);
select zloz_zamowienie(1, 3, 17, 38, 40, 81, null);
select zloz_zamowienie(1, 3, 31, 43, 40, 64, null);
select zloz_zamowienie(1, 4, 28, 29, 40, 8, null);
select zloz_zamowienie(1, 1, 18, 23, 40, 55, null);
select zloz_zamowienie(1, 4, 40, 39, 40, 5, null);
select zloz_zamowienie(2, 3, 17, 24, 41, 7, null);
select zloz_zamowienie(1, 4, 45, 16, 41, 74, null);
select zloz_zamowienie(1, 2, 25, 7, 41, 24, null);
select zloz_zamowienie(1, 1, 21, 43, 41, 5, null);
select zloz_zamowienie(1, 4, 27, 41, 41, 36, null);
select zloz_zamowienie(2, 2, 40, 42, 41, 26, null);
select zloz_zamowienie(2, 4, 30, 3, 41, 66, null);
select zloz_zamowienie(2, 3, 6, 1, 41, 24, null);
select zloz_zamowienie(2, 3, 7, 8, 41, 4, null);
select zloz_zamowienie(1, 2, 22, 47, 41, 48, null);
select zloz_zamowienie(1, 3, 18, 37, 41, 96, null);
select zloz_zamowienie(1, 3, 43, 32, 41, 36, null);
select zloz_zamowienie(1, 2, 41, 31, 41, 70, null);
select zloz_zamowienie(1, 2, 7, 8, 41, 60, null);
select zloz_zamowienie(1, 2, 47, 9, 41, 34, null);
select zloz_zamowienie(1, 2, 14, 31, 41, 29, null);
select zloz_zamowienie(1, 1, 37, 8, 41, 76, null);
select zloz_zamowienie(2, 3, 27, 8, 41, 58, null);
select zloz_zamowienie(1, 2, 13, 27, 41, 12, null);
select zloz_zamowienie(2, 3, 19, 24, 41, 19, null);
select zloz_zamowienie(2, 1, 9, 11, 42, 16, null);
select zloz_zamowienie(1, 4, 31, 41, 42, 86, null);
select zloz_zamowienie(1, 4, 42, 27, 42, 18, null);
select zloz_zamowienie(2, 2, 17, 23, 42, 57, null);
select zloz_zamowienie(2, 2, 23, 19, 42, 47, null);
select zloz_zamowienie(1, 3, 5, 43, 42, 28, null);
select zloz_zamowienie(2, 4, 42, 29, 42, 65, null);
select zloz_zamowienie(2, 2, 39, 31, 42, 40, null);
select zloz_zamowienie(1, 2, 6, 36, 42, 58, null);
select zloz_zamowienie(2, 2, 20, 27, 42, 99, null);
select zloz_zamowienie(2, 4, 30, 8, 42, 79, null);
select zloz_zamowienie(1, 2, 18, 5, 42, 93, null);
select zloz_zamowienie(1, 1, 27, 25, 42, 48, null);
select zloz_zamowienie(2, 3, 17, 26, 42, 62, null);
select zloz_zamowienie(1, 1, 35, 43, 42, 40, null);
select zloz_zamowienie(1, 4, 41, 38, 42, 4, null);
select zloz_zamowienie(2, 4, 42, 28, 42, 51, null);
select zloz_zamowienie(2, 3, 42, 50, 42, 94, null);
select zloz_zamowienie(2, 4, 31, 45, 42, 60, null);
select zloz_zamowienie(2, 2, 22, 39, 42, 23, null);
select zloz_zamowienie(1, 1, 10, 36, 43, 66, null);
select zloz_zamowienie(2, 3, 33, 26, 43, 60, null);
select zloz_zamowienie(2, 3, 5, 23, 43, 54, null);
select zloz_zamowienie(1, 2, 29, 19, 43, 56, null);
select zloz_zamowienie(2, 3, 34, 17, 43, 26, null);
select zloz_zamowienie(1, 1, 48, 40, 43, 27, null);
select zloz_zamowienie(2, 2, 42, 26, 43, 80, null);
select zloz_zamowienie(1, 4, 22, 1, 43, 45, null);
select zloz_zamowienie(1, 3, 9, 5, 43, 98, null);
select zloz_zamowienie(2, 3, 21, 16, 43, 93, null);
select zloz_zamowienie(1, 1, 39, 31, 43, 8, null);
select zloz_zamowienie(1, 2, 38, 45, 43, 100, null);
select zloz_zamowienie(1, 1, 1, 42, 43, 6, null);
select zloz_zamowienie(1, 3, 27, 21, 43, 93, null);
select zloz_zamowienie(2, 4, 39, 2, 43, 66, null);
select zloz_zamowienie(2, 2, 29, 9, 43, 75, null);
select zloz_zamowienie(1, 4, 3, 34, 43, 54, null);
select zloz_zamowienie(2, 4, 14, 47, 43, 27, null);
select zloz_zamowienie(2, 1, 12, 29, 43, 29, null);
select zloz_zamowienie(2, 4, 37, 50, 43, 14, null);
select zloz_zamowienie(1, 1, 19, 31, 44, 64, null);
select zloz_zamowienie(1, 3, 42, 39, 44, 76, null);
select zloz_zamowienie(1, 2, 46, 26, 44, 86, null);
select zloz_zamowienie(2, 1, 28, 23, 44, 25, null);
select zloz_zamowienie(1, 1, 25, 30, 44, 57, null);
select zloz_zamowienie(2, 1, 26, 29, 44, 96, null);
select zloz_zamowienie(2, 2, 11, 27, 44, 4, null);
select zloz_zamowienie(2, 3, 5, 3, 44, 13, null);
select zloz_zamowienie(1, 2, 42, 9, 44, 4, null);
select zloz_zamowienie(1, 3, 40, 37, 44, 80, null);
select zloz_zamowienie(1, 2, 13, 46, 44, 24, null);
select zloz_zamowienie(2, 4, 23, 4, 44, 99, null);
select zloz_zamowienie(1, 4, 29, 25, 44, 47, null);
select zloz_zamowienie(1, 2, 24, 32, 44, 4, null);
select zloz_zamowienie(1, 4, 20, 16, 44, 42, null);
select zloz_zamowienie(1, 3, 42, 50, 44, 10, null);
select zloz_zamowienie(1, 1, 23, 33, 44, 61, null);
select zloz_zamowienie(1, 3, 5, 16, 44, 68, null);
select zloz_zamowienie(2, 4, 10, 33, 44, 14, null);
select zloz_zamowienie(2, 4, 14, 26, 44, 34, null);
select zloz_zamowienie(1, 1, 12, 49, 45, 65, null);
select zloz_zamowienie(2, 1, 26, 50, 45, 52, null);
select zloz_zamowienie(2, 4, 32, 31, 45, 57, null);
select zloz_zamowienie(2, 2, 33, 35, 45, 99, null);
select zloz_zamowienie(2, 2, 14, 11, 45, 14, null);
select zloz_zamowienie(1, 3, 14, 45, 45, 69, null);
select zloz_zamowienie(1, 4, 25, 37, 45, 27, null);
select zloz_zamowienie(2, 4, 47, 14, 45, 96, null);
select zloz_zamowienie(1, 1, 15, 21, 45, 14, null);
select zloz_zamowienie(2, 3, 22, 14, 45, 30, null);
select zloz_zamowienie(2, 2, 34, 23, 45, 2, null);
select zloz_zamowienie(2, 1, 1, 8, 45, 99, null);
select zloz_zamowienie(1, 4, 22, 11, 45, 41, null);
select zloz_zamowienie(2, 4, 46, 35, 45, 50, null);
select zloz_zamowienie(1, 3, 23, 37, 45, 75, null);
select zloz_zamowienie(2, 4, 38, 32, 45, 44, null);
select zloz_zamowienie(1, 4, 7, 30, 45, 39, null);
select zloz_zamowienie(2, 2, 3, 25, 45, 55, null);
select zloz_zamowienie(1, 2, 20, 31, 45, 72, null);
select zloz_zamowienie(1, 4, 27, 41, 45, 51, null);
select zloz_zamowienie(1, 4, 40, 19, 46, 34, null);
select zloz_zamowienie(2, 1, 24, 35, 46, 6, null);
select zloz_zamowienie(2, 1, 21, 42, 46, 72, null);
select zloz_zamowienie(1, 2, 44, 47, 46, 33, null);
select zloz_zamowienie(2, 1, 45, 4, 46, 70, null);
select zloz_zamowienie(1, 3, 20, 33, 46, 70, null);
select zloz_zamowienie(1, 2, 34, 13, 46, 70, null);
select zloz_zamowienie(1, 3, 29, 4, 46, 47, null);
select zloz_zamowienie(1, 2, 14, 28, 46, 98, null);
select zloz_zamowienie(1, 2, 18, 28, 46, 89, null);
select zloz_zamowienie(2, 3, 42, 12, 46, 59, null);
select zloz_zamowienie(2, 3, 21, 12, 46, 36, null);
select zloz_zamowienie(1, 3, 42, 34, 46, 87, null);
select zloz_zamowienie(1, 3, 43, 32, 46, 41, null);
select zloz_zamowienie(1, 1, 34, 16, 46, 89, null);
select zloz_zamowienie(1, 4, 16, 19, 46, 1, null);
select zloz_zamowienie(2, 4, 28, 2, 46, 16, null);
select zloz_zamowienie(1, 4, 20, 9, 46, 8, null);
select zloz_zamowienie(2, 1, 37, 5, 46, 71, null);
select zloz_zamowienie(2, 4, 9, 41, 46, 13, null);
select zloz_zamowienie(2, 1, 39, 35, 47, 81, null);
select zloz_zamowienie(2, 1, 44, 47, 47, 68, null);
select zloz_zamowienie(2, 3, 35, 7, 47, 91, null);
select zloz_zamowienie(1, 2, 4, 15, 47, 10, null);
select zloz_zamowienie(2, 2, 5, 16, 47, 50, null);
select zloz_zamowienie(1, 4, 44, 34, 47, 49, null);
select zloz_zamowienie(2, 2, 31, 21, 47, 51, null);
select zloz_zamowienie(1, 2, 43, 22, 47, 64, null);
select zloz_zamowienie(1, 4, 46, 5, 47, 71, null);
select zloz_zamowienie(1, 2, 20, 49, 47, 52, null);
select zloz_zamowienie(1, 4, 42, 25, 47, 11, null);
select zloz_zamowienie(1, 2, 28, 13, 47, 94, null);
select zloz_zamowienie(2, 3, 11, 9, 47, 55, null);
select zloz_zamowienie(2, 2, 6, 37, 47, 26, null);
select zloz_zamowienie(1, 3, 31, 46, 47, 16, null);
select zloz_zamowienie(1, 3, 35, 30, 47, 5, null);
select zloz_zamowienie(1, 1, 2, 11, 47, 81, null);
select zloz_zamowienie(2, 1, 22, 14, 47, 46, null);
select zloz_zamowienie(2, 1, 12, 16, 47, 51, null);
select zloz_zamowienie(1, 2, 38, 2, 47, 6, null);
select zloz_zamowienie(2, 1, 39, 10, 48, 96, null);
select zloz_zamowienie(1, 1, 33, 31, 48, 85, null);
select zloz_zamowienie(1, 1, 32, 47, 48, 68, null);
select zloz_zamowienie(1, 2, 11, 32, 48, 39, null);
select zloz_zamowienie(2, 4, 27, 23, 48, 19, null);
select zloz_zamowienie(1, 4, 34, 29, 48, 20, null);
select zloz_zamowienie(1, 1, 41, 50, 48, 78, null);
select zloz_zamowienie(1, 2, 14, 17, 48, 18, null);
select zloz_zamowienie(1, 3, 48, 39, 48, 78, null);
select zloz_zamowienie(2, 1, 43, 36, 48, 92, null);
select zloz_zamowienie(2, 1, 23, 26, 48, 16, null);
select zloz_zamowienie(2, 1, 45, 37, 48, 92, null);
select zloz_zamowienie(2, 3, 8, 13, 48, 20, null);
select zloz_zamowienie(2, 3, 50, 48, 48, 73, null);
select zloz_zamowienie(2, 1, 14, 43, 48, 17, null);
select zloz_zamowienie(1, 4, 16, 49, 48, 92, null);
select zloz_zamowienie(2, 2, 13, 18, 48, 72, null);
select zloz_zamowienie(2, 4, 38, 7, 48, 74, null);
select zloz_zamowienie(1, 3, 20, 6, 48, 13, null);
select zloz_zamowienie(2, 1, 43, 2, 48, 43, null);
select zloz_zamowienie(1, 2, 24, 32, 49, 83, null);
select zloz_zamowienie(2, 1, 12, 20, 49, 68, null);
select zloz_zamowienie(2, 1, 36, 8, 49, 88, null);
select zloz_zamowienie(2, 4, 3, 35, 49, 76, null);
select zloz_zamowienie(2, 2, 18, 10, 49, 59, null);
select zloz_zamowienie(2, 1, 18, 27, 49, 47, null);
select zloz_zamowienie(2, 1, 44, 17, 49, 9, null);
select zloz_zamowienie(1, 3, 39, 6, 49, 84, null);
select zloz_zamowienie(1, 3, 47, 35, 49, 34, null);
select zloz_zamowienie(2, 2, 46, 12, 49, 78, null);
select zloz_zamowienie(1, 1, 3, 37, 49, 53, null);
select zloz_zamowienie(1, 2, 49, 1, 49, 15, null);
select zloz_zamowienie(2, 3, 50, 1, 49, 58, null);
select zloz_zamowienie(1, 2, 27, 39, 49, 6, null);
select zloz_zamowienie(1, 2, 44, 8, 49, 52, null);
select zloz_zamowienie(2, 3, 17, 31, 49, 50, null);
select zloz_zamowienie(1, 4, 30, 4, 49, 83, null);
select zloz_zamowienie(1, 3, 11, 37, 49, 66, null);
select zloz_zamowienie(1, 4, 36, 10, 49, 41, null);
select zloz_zamowienie(2, 3, 35, 14, 49, 46, null);
select zloz_zamowienie(2, 1, 33, 3, 50, 38, null);
select zloz_zamowienie(2, 3, 25, 39, 50, 62, null);
select zloz_zamowienie(2, 3, 2, 45, 50, 85, null);
select zloz_zamowienie(2, 4, 12, 42, 50, 35, null);
select zloz_zamowienie(1, 4, 3, 44, 50, 76, null);
select zloz_zamowienie(2, 4, 29, 1, 50, 35, null);
select zloz_zamowienie(2, 3, 7, 49, 50, 83, null);
select zloz_zamowienie(2, 2, 39, 9, 50, 81, null);
select zloz_zamowienie(2, 2, 5, 1, 50, 2, null);
select zloz_zamowienie(1, 2, 44, 24, 50, 53, null);
select zloz_zamowienie(2, 1, 37, 40, 50, 41, null);
select zloz_zamowienie(2, 2, 25, 41, 50, 52, null);
select zloz_zamowienie(2, 3, 38, 39, 50, 46, null);
select zloz_zamowienie(1, 3, 17, 38, 50, 37, null);
select zloz_zamowienie(2, 4, 5, 44, 50, 85, null);
select zloz_zamowienie(1, 2, 47, 27, 50, 30, null);
select zloz_zamowienie(1, 3, 18, 2, 50, 23, null);
select zloz_zamowienie(1, 2, 25, 21, 50, 25, null);
select zloz_zamowienie(2, 2, 19, 5, 50, 64, null);
select zloz_zamowienie(1, 1, 39, 4, 50, 63, null);
select zloz_zamowienie(1, 3, 38, 43, 51, 12, null);
select zloz_zamowienie(1, 4, 32, 19, 51, 43, null);
select zloz_zamowienie(2, 2, 36, 24, 51, 12, null);
select zloz_zamowienie(2, 4, 45, 1, 51, 59, null);
select zloz_zamowienie(2, 2, 33, 11, 51, 54, null);
select zloz_zamowienie(1, 3, 2, 31, 51, 33, null);
select zloz_zamowienie(2, 3, 25, 22, 51, 88, null);
select zloz_zamowienie(2, 1, 42, 23, 51, 6, null);
select zloz_zamowienie(1, 1, 27, 16, 51, 62, null);
select zloz_zamowienie(2, 4, 33, 39, 51, 87, null);
select zloz_zamowienie(1, 3, 44, 25, 51, 67, null);
select zloz_zamowienie(2, 4, 48, 3, 51, 92, null);
select zloz_zamowienie(1, 4, 19, 42, 51, 18, null);
select zloz_zamowienie(2, 4, 2, 12, 51, 85, null);
select zloz_zamowienie(1, 2, 14, 9, 51, 8, null);
select zloz_zamowienie(1, 3, 24, 13, 51, 95, null);
select zloz_zamowienie(1, 3, 12, 27, 51, 4, null);
select zloz_zamowienie(2, 2, 27, 3, 51, 30, null);
select zloz_zamowienie(2, 3, 40, 12, 51, 16, null);
select zloz_zamowienie(1, 4, 12, 14, 51, 9, null);
select zloz_zamowienie(1, 1, 29, 31, 52, 81, null);
select zloz_zamowienie(1, 4, 1, 35, 52, 70, null);
select zloz_zamowienie(1, 1, 29, 9, 52, 94, null);
select zloz_zamowienie(1, 4, 12, 5, 52, 49, null);
select zloz_zamowienie(2, 3, 7, 46, 52, 84, null);
select zloz_zamowienie(2, 3, 2, 3, 52, 58, null);
select zloz_zamowienie(1, 2, 28, 18, 52, 4, null);
select zloz_zamowienie(2, 1, 9, 1, 52, 55, null);
select zloz_zamowienie(2, 1, 29, 24, 52, 73, null);
select zloz_zamowienie(2, 4, 19, 37, 52, 56, null);
select zloz_zamowienie(1, 2, 10, 25, 52, 100, null);
select zloz_zamowienie(1, 3, 33, 28, 52, 45, null);
select zloz_zamowienie(1, 4, 6, 29, 52, 72, null);
select zloz_zamowienie(2, 1, 24, 36, 52, 24, null);
select zloz_zamowienie(2, 3, 31, 32, 52, 6, null);
select zloz_zamowienie(1, 3, 46, 15, 52, 98, null);
select zloz_zamowienie(1, 3, 18, 43, 52, 7, null);
select zloz_zamowienie(2, 3, 28, 4, 52, 53, null);
select zloz_zamowienie(1, 2, 16, 9, 52, 30, null);
select zloz_zamowienie(1, 2, 5, 37, 52, 48, null);
select zloz_zamowienie(2, 3, 20, 5, 53, 80, null);
select zloz_zamowienie(1, 3, 48, 42, 53, 60, null);
select zloz_zamowienie(2, 2, 50, 47, 53, 71, null);
select zloz_zamowienie(1, 1, 5, 41, 53, 14, null);
select zloz_zamowienie(2, 4, 7, 50, 53, 14, null);
select zloz_zamowienie(1, 4, 9, 42, 53, 66, null);
select zloz_zamowienie(2, 4, 8, 31, 53, 95, null);
select zloz_zamowienie(1, 2, 36, 26, 53, 7, null);
select zloz_zamowienie(2, 4, 4, 46, 53, 98, null);
select zloz_zamowienie(2, 4, 33, 21, 53, 54, null);
select zloz_zamowienie(2, 4, 16, 20, 53, 82, null);
select zloz_zamowienie(2, 2, 18, 40, 53, 98, null);
select zloz_zamowienie(2, 2, 40, 6, 53, 13, null);
select zloz_zamowienie(2, 1, 48, 20, 53, 41, null);
select zloz_zamowienie(2, 4, 8, 5, 53, 61, null);
select zloz_zamowienie(1, 2, 37, 11, 53, 37, null);
select zloz_zamowienie(1, 2, 34, 37, 53, 60, null);
select zloz_zamowienie(2, 3, 36, 18, 53, 42, null);
select zloz_zamowienie(1, 1, 10, 6, 53, 12, null);
select zloz_zamowienie(1, 3, 11, 46, 53, 90, null);
select zloz_zamowienie(1, 3, 7, 34, 54, 89, null);
select zloz_zamowienie(2, 1, 23, 50, 54, 83, null);
select zloz_zamowienie(1, 1, 44, 13, 54, 39, null);
select zloz_zamowienie(2, 3, 17, 35, 54, 32, null);
select zloz_zamowienie(2, 1, 10, 9, 54, 57, null);
select zloz_zamowienie(1, 4, 4, 3, 54, 36, null);
select zloz_zamowienie(2, 1, 31, 47, 54, 15, null);
select zloz_zamowienie(2, 3, 31, 37, 54, 81, null);
select zloz_zamowienie(1, 2, 46, 40, 54, 74, null);
select zloz_zamowienie(1, 4, 9, 49, 54, 26, null);
select zloz_zamowienie(2, 2, 44, 42, 54, 43, null);
select zloz_zamowienie(2, 4, 40, 47, 54, 34, null);
select zloz_zamowienie(1, 2, 47, 28, 54, 86, null);
select zloz_zamowienie(2, 3, 14, 31, 54, 10, null);
select zloz_zamowienie(1, 2, 32, 11, 54, 97, null);
select zloz_zamowienie(2, 2, 41, 17, 54, 40, null);
select zloz_zamowienie(1, 3, 27, 30, 54, 15, null);
select zloz_zamowienie(2, 4, 26, 19, 54, 36, null);
select zloz_zamowienie(2, 4, 15, 22, 54, 21, null);
select zloz_zamowienie(2, 3, 45, 7, 54, 67, null);
select zloz_zamowienie(1, 3, 49, 10, 55, 10, null);
select zloz_zamowienie(2, 4, 26, 41, 55, 44, null);
select zloz_zamowienie(1, 1, 4, 24, 55, 45, null);
select zloz_zamowienie(2, 2, 5, 4, 55, 79, null);
select zloz_zamowienie(2, 2, 14, 42, 55, 8, null);
select zloz_zamowienie(2, 3, 26, 32, 55, 60, null);
select zloz_zamowienie(1, 1, 23, 44, 55, 90, null);
select zloz_zamowienie(1, 1, 30, 5, 55, 25, null);
select zloz_zamowienie(2, 4, 46, 18, 55, 88, null);
select zloz_zamowienie(1, 3, 50, 26, 55, 23, null);
select zloz_zamowienie(2, 2, 10, 22, 55, 7, null);
select zloz_zamowienie(2, 4, 9, 38, 55, 96, null);
select zloz_zamowienie(1, 3, 30, 13, 55, 21, null);
select zloz_zamowienie(2, 2, 13, 30, 55, 86, null);
select zloz_zamowienie(1, 2, 43, 23, 55, 80, null);
select zloz_zamowienie(1, 3, 3, 47, 55, 71, null);
select zloz_zamowienie(2, 3, 32, 18, 55, 58, null);
select zloz_zamowienie(1, 2, 43, 28, 55, 91, null);
select zloz_zamowienie(2, 1, 6, 30, 55, 83, null);
select zloz_zamowienie(1, 4, 11, 45, 55, 44, null);
select zloz_zamowienie(1, 4, 1, 41, 56, 70, null);
select zloz_zamowienie(2, 3, 19, 17, 56, 76, null);
select zloz_zamowienie(2, 1, 19, 12, 56, 90, null);
select zloz_zamowienie(1, 4, 46, 9, 56, 95, null);
select zloz_zamowienie(1, 3, 6, 21, 56, 25, null);
select zloz_zamowienie(2, 2, 7, 13, 56, 65, null);
select zloz_zamowienie(1, 3, 46, 27, 56, 9, null);
select zloz_zamowienie(2, 4, 20, 5, 56, 78, null);
select zloz_zamowienie(1, 3, 35, 38, 56, 90, null);
select zloz_zamowienie(2, 2, 49, 28, 56, 24, null);
select zloz_zamowienie(2, 3, 39, 6, 56, 48, null);
select zloz_zamowienie(1, 1, 44, 17, 56, 40, null);
select zloz_zamowienie(1, 1, 4, 23, 56, 82, null);
select zloz_zamowienie(1, 2, 39, 5, 56, 30, null);
select zloz_zamowienie(1, 2, 44, 31, 56, 40, null);
select zloz_zamowienie(2, 4, 31, 33, 56, 97, null);
select zloz_zamowienie(1, 4, 39, 28, 56, 25, null);
select zloz_zamowienie(2, 1, 17, 46, 56, 44, null);
select zloz_zamowienie(2, 1, 1, 11, 56, 94, null);
select zloz_zamowienie(2, 4, 48, 28, 56, 43, null);
select zloz_zamowienie(2, 3, 22, 23, 57, 28, null);
select zloz_zamowienie(2, 3, 45, 13, 57, 97, null);
select zloz_zamowienie(1, 4, 13, 22, 57, 56, null);
select zloz_zamowienie(2, 3, 19, 4, 57, 2, null);
select zloz_zamowienie(2, 2, 18, 13, 57, 83, null);
select zloz_zamowienie(1, 1, 32, 39, 57, 43, null);
select zloz_zamowienie(1, 4, 18, 31, 57, 70, null);
select zloz_zamowienie(1, 3, 1, 30, 57, 89, null);
select zloz_zamowienie(1, 1, 43, 31, 57, 38, null);
select zloz_zamowienie(2, 2, 15, 38, 57, 68, null);
select zloz_zamowienie(1, 2, 23, 43, 57, 25, null);
select zloz_zamowienie(1, 2, 23, 41, 57, 15, null);
select zloz_zamowienie(2, 4, 30, 48, 57, 62, null);
select zloz_zamowienie(2, 2, 22, 28, 57, 65, null);
select zloz_zamowienie(2, 3, 6, 9, 57, 97, null);
select zloz_zamowienie(2, 4, 23, 27, 57, 13, null);
select zloz_zamowienie(2, 1, 14, 50, 57, 38, null);
select zloz_zamowienie(2, 1, 34, 27, 57, 75, null);
select zloz_zamowienie(2, 3, 40, 23, 57, 39, null);
select zloz_zamowienie(1, 3, 23, 31, 57, 9, null);
select zloz_zamowienie(1, 2, 27, 9, 58, 36, null);
select zloz_zamowienie(1, 2, 48, 39, 58, 72, null);
select zloz_zamowienie(2, 1, 22, 46, 58, 98, null);
select zloz_zamowienie(1, 3, 12, 29, 58, 97, null);
select zloz_zamowienie(2, 2, 16, 9, 58, 13, null);
select zloz_zamowienie(2, 4, 35, 37, 58, 51, null);
select zloz_zamowienie(1, 2, 3, 40, 58, 50, null);
select zloz_zamowienie(2, 1, 23, 36, 58, 72, null);
select zloz_zamowienie(1, 1, 23, 48, 58, 2, null);
select zloz_zamowienie(1, 1, 9, 36, 58, 80, null);
select zloz_zamowienie(2, 3, 32, 48, 58, 63, null);
select zloz_zamowienie(2, 2, 17, 47, 58, 7, null);
select zloz_zamowienie(1, 4, 7, 50, 58, 43, null);
select zloz_zamowienie(2, 3, 50, 41, 58, 40, null);
select zloz_zamowienie(2, 1, 43, 19, 58, 35, null);
select zloz_zamowienie(1, 4, 25, 46, 58, 62, null);
select zloz_zamowienie(2, 1, 22, 36, 58, 9, null);
select zloz_zamowienie(1, 4, 45, 23, 58, 100, null);
select zloz_zamowienie(2, 1, 22, 10, 58, 72, null);
select zloz_zamowienie(2, 4, 45, 2, 58, 26, null);
select zloz_zamowienie(1, 4, 30, 42, 59, 27, null);
select zloz_zamowienie(1, 4, 49, 4, 59, 25, null);
select zloz_zamowienie(2, 1, 9, 7, 59, 69, null);
select zloz_zamowienie(1, 3, 6, 31, 59, 84, null);
select zloz_zamowienie(2, 4, 20, 11, 59, 69, null);
select zloz_zamowienie(1, 1, 26, 49, 59, 33, null);
select zloz_zamowienie(2, 3, 18, 4, 59, 54, null);
select zloz_zamowienie(1, 4, 25, 30, 59, 28, null);
select zloz_zamowienie(2, 2, 28, 48, 59, 68, null);
select zloz_zamowienie(1, 2, 47, 35, 59, 73, null);
select zloz_zamowienie(1, 3, 8, 9, 59, 95, null);
select zloz_zamowienie(2, 3, 48, 5, 59, 38, null);
select zloz_zamowienie(1, 4, 40, 28, 59, 39, null);
select zloz_zamowienie(2, 1, 30, 5, 59, 38, null);
select zloz_zamowienie(2, 2, 31, 49, 59, 65, null);
select zloz_zamowienie(2, 1, 36, 18, 59, 20, null);
select zloz_zamowienie(2, 2, 3, 13, 59, 26, null);
select zloz_zamowienie(2, 4, 42, 8, 59, 100, null);
select zloz_zamowienie(1, 4, 47, 38, 59, 95, null);
select zloz_zamowienie(1, 1, 21, 30, 59, 33, null);
select zloz_zamowienie(2, 4, 15, 46, 60, 94, null);
select zloz_zamowienie(2, 4, 49, 32, 60, 80, null);
select zloz_zamowienie(2, 1, 18, 9, 60, 44, null);
select zloz_zamowienie(2, 4, 28, 50, 60, 42, null);
select zloz_zamowienie(1, 4, 9, 41, 60, 35, null);
select zloz_zamowienie(2, 4, 20, 47, 60, 8, null);
select zloz_zamowienie(2, 3, 24, 37, 60, 81, null);
select zloz_zamowienie(2, 3, 10, 46, 60, 17, null);
select zloz_zamowienie(1, 1, 45, 27, 60, 86, null);
select zloz_zamowienie(1, 3, 50, 36, 60, 96, null);
select zloz_zamowienie(1, 3, 12, 26, 60, 89, null);
select zloz_zamowienie(1, 2, 7, 5, 60, 14, null);
select zloz_zamowienie(1, 2, 1, 8, 60, 7, null);
select zloz_zamowienie(2, 3, 23, 29, 60, 15, null);
select zloz_zamowienie(2, 2, 25, 14, 60, 1, null);
select zloz_zamowienie(2, 2, 27, 19, 60, 39, null);
select zloz_zamowienie(2, 4, 33, 25, 60, 32, null);
select zloz_zamowienie(1, 3, 45, 24, 60, 33, null);
select zloz_zamowienie(2, 1, 1, 36, 60, 47, null);
select zloz_zamowienie(2, 1, 17, 18, 60, 85, null);
select zloz_zamowienie(1, 3, 14, 35, 61, 54, null);
select zloz_zamowienie(2, 3, 21, 28, 61, 46, null);
select zloz_zamowienie(1, 1, 6, 10, 61, 70, null);
select zloz_zamowienie(1, 1, 3, 34, 61, 44, null);
select zloz_zamowienie(2, 4, 34, 29, 61, 82, null);
select zloz_zamowienie(2, 1, 24, 25, 61, 34, null);
select zloz_zamowienie(1, 3, 24, 29, 61, 57, null);
select zloz_zamowienie(2, 3, 16, 39, 61, 72, null);
select zloz_zamowienie(1, 1, 32, 10, 61, 63, null);
select zloz_zamowienie(2, 1, 2, 21, 61, 60, null);
select zloz_zamowienie(2, 2, 19, 9, 61, 48, null);
select zloz_zamowienie(2, 3, 4, 15, 61, 63, null);
select zloz_zamowienie(1, 2, 4, 10, 61, 2, null);
select zloz_zamowienie(1, 1, 34, 46, 61, 64, null);
select zloz_zamowienie(1, 4, 48, 5, 61, 67, null);
select zloz_zamowienie(1, 2, 15, 45, 61, 27, null);
select zloz_zamowienie(2, 3, 43, 7, 61, 68, null);
select zloz_zamowienie(1, 1, 9, 33, 61, 39, null);
select zloz_zamowienie(1, 4, 21, 39, 61, 11, null);
select zloz_zamowienie(1, 4, 18, 50, 61, 37, null);
select zloz_zamowienie(2, 4, 6, 46, 62, 50, null);
select zloz_zamowienie(2, 1, 6, 31, 62, 29, null);
select zloz_zamowienie(2, 1, 47, 24, 62, 20, null);
select zloz_zamowienie(1, 1, 42, 16, 62, 35, null);
select zloz_zamowienie(2, 4, 49, 22, 62, 94, null);
select zloz_zamowienie(1, 1, 50, 24, 62, 64, null);
select zloz_zamowienie(2, 2, 39, 27, 62, 76, null);
select zloz_zamowienie(2, 3, 27, 43, 62, 51, null);
select zloz_zamowienie(2, 4, 43, 10, 62, 68, null);
select zloz_zamowienie(1, 2, 3, 48, 62, 59, null);
select zloz_zamowienie(1, 3, 16, 30, 62, 78, null);
select zloz_zamowienie(2, 2, 34, 46, 62, 94, null);
select zloz_zamowienie(1, 3, 22, 7, 62, 73, null);
select zloz_zamowienie(1, 2, 27, 28, 62, 97, null);
select zloz_zamowienie(2, 4, 36, 6, 62, 3, null);
select zloz_zamowienie(1, 2, 25, 32, 62, 77, null);
select zloz_zamowienie(1, 2, 42, 43, 62, 83, null);
select zloz_zamowienie(2, 1, 9, 3, 62, 96, null);
select zloz_zamowienie(2, 4, 40, 12, 62, 72, null);
select zloz_zamowienie(1, 1, 6, 10, 62, 22, null);
select zloz_zamowienie(2, 4, 32, 44, 63, 32, null);
select zloz_zamowienie(1, 4, 8, 44, 63, 26, null);
select zloz_zamowienie(1, 3, 23, 12, 63, 37, null);
select zloz_zamowienie(1, 1, 29, 2, 63, 40, null);
select zloz_zamowienie(1, 1, 31, 2, 63, 2, null);
select zloz_zamowienie(1, 1, 45, 30, 63, 62, null);
select zloz_zamowienie(1, 2, 41, 47, 63, 98, null);
select zloz_zamowienie(2, 3, 41, 27, 63, 73, null);
select zloz_zamowienie(2, 4, 31, 30, 63, 62, null);
select zloz_zamowienie(1, 1, 17, 50, 63, 87, null);
select zloz_zamowienie(1, 2, 39, 38, 63, 73, null);
select zloz_zamowienie(1, 3, 45, 25, 63, 18, null);
select zloz_zamowienie(2, 4, 5, 19, 63, 89, null);
select zloz_zamowienie(1, 3, 41, 16, 63, 45, null);
select zloz_zamowienie(1, 2, 40, 48, 63, 20, null);
select zloz_zamowienie(1, 1, 10, 15, 63, 7, null);
select zloz_zamowienie(2, 1, 44, 41, 63, 69, null);
select zloz_zamowienie(1, 2, 13, 23, 63, 42, null);
select zloz_zamowienie(1, 4, 3, 2, 63, 50, null);
select zloz_zamowienie(1, 2, 50, 7, 63, 12, null);
select zloz_zamowienie(2, 2, 19, 16, 64, 53, null);
select zloz_zamowienie(1, 1, 2, 21, 64, 70, null);
select zloz_zamowienie(1, 1, 10, 13, 64, 53, null);
select zloz_zamowienie(2, 4, 34, 9, 64, 57, null);
select zloz_zamowienie(1, 1, 46, 34, 64, 78, null);
select zloz_zamowienie(2, 1, 15, 23, 64, 40, null);
select zloz_zamowienie(1, 3, 18, 15, 64, 1, null);
select zloz_zamowienie(2, 1, 18, 39, 64, 88, null);
select zloz_zamowienie(1, 1, 13, 26, 64, 80, null);
select zloz_zamowienie(1, 3, 16, 22, 64, 35, null);
select zloz_zamowienie(2, 4, 20, 46, 64, 9, null);
select zloz_zamowienie(2, 3, 34, 3, 64, 43, null);
select zloz_zamowienie(2, 1, 48, 36, 64, 96, null);
select zloz_zamowienie(2, 2, 2, 16, 64, 99, null);
select zloz_zamowienie(2, 2, 24, 26, 64, 9, null);
select zloz_zamowienie(1, 2, 19, 40, 64, 71, null);
select zloz_zamowienie(1, 2, 43, 19, 64, 61, null);
select zloz_zamowienie(1, 1, 18, 22, 64, 54, null);
select zloz_zamowienie(1, 2, 48, 13, 64, 14, null);
select zloz_zamowienie(2, 3, 20, 48, 64, 25, null);
select zloz_zamowienie(2, 4, 42, 26, 65, 64, null);
select zloz_zamowienie(1, 1, 2, 12, 65, 19, null);
select zloz_zamowienie(1, 1, 37, 47, 65, 45, null);
select zloz_zamowienie(1, 3, 26, 1, 65, 63, null);
select zloz_zamowienie(1, 3, 6, 36, 65, 49, null);
select zloz_zamowienie(1, 1, 1, 34, 65, 46, null);
select zloz_zamowienie(2, 1, 27, 28, 65, 49, null);
select zloz_zamowienie(1, 3, 23, 20, 65, 4, null);
select zloz_zamowienie(2, 3, 30, 18, 65, 95, null);
select zloz_zamowienie(1, 1, 9, 38, 65, 59, null);
select zloz_zamowienie(2, 1, 12, 15, 65, 99, null);
select zloz_zamowienie(1, 2, 18, 27, 65, 100, null);
select zloz_zamowienie(1, 3, 14, 12, 65, 62, null);
select zloz_zamowienie(1, 2, 13, 17, 65, 91, null);
select zloz_zamowienie(1, 3, 6, 33, 65, 79, null);
select zloz_zamowienie(2, 3, 44, 43, 65, 76, null);
select zloz_zamowienie(2, 4, 24, 25, 65, 92, null);
select zloz_zamowienie(1, 1, 12, 28, 65, 58, null);
select zloz_zamowienie(1, 1, 40, 16, 65, 11, null);
select zloz_zamowienie(2, 4, 16, 42, 65, 59, null);
select zloz_zamowienie(1, 2, 42, 12, 66, 89, null);
select zloz_zamowienie(1, 1, 29, 8, 66, 53, null);
select zloz_zamowienie(1, 2, 32, 11, 66, 34, null);
select zloz_zamowienie(1, 1, 22, 40, 66, 50, null);
select zloz_zamowienie(2, 2, 49, 33, 66, 77, null);
select zloz_zamowienie(2, 3, 37, 39, 66, 53, null);
select zloz_zamowienie(2, 3, 24, 13, 66, 16, null);
select zloz_zamowienie(1, 4, 16, 23, 66, 65, null);
select zloz_zamowienie(1, 1, 49, 39, 66, 20, null);
select zloz_zamowienie(1, 2, 49, 22, 66, 53, null);
select zloz_zamowienie(2, 4, 37, 50, 66, 10, null);
select zloz_zamowienie(1, 2, 44, 15, 66, 71, null);
select zloz_zamowienie(2, 3, 34, 21, 66, 76, null);
select zloz_zamowienie(2, 3, 39, 49, 66, 35, null);
select zloz_zamowienie(2, 4, 36, 1, 66, 6, null);
select zloz_zamowienie(1, 4, 33, 30, 66, 32, null);
select zloz_zamowienie(1, 1, 4, 47, 66, 98, null);
select zloz_zamowienie(1, 2, 19, 30, 66, 50, null);
select zloz_zamowienie(2, 3, 39, 21, 66, 46, null);
select zloz_zamowienie(1, 3, 18, 34, 66, 61, null);
select zloz_zamowienie(2, 2, 30, 19, 67, 19, null);
select zloz_zamowienie(2, 2, 23, 3, 67, 1, null);
select zloz_zamowienie(2, 1, 32, 13, 67, 61, null);
select zloz_zamowienie(1, 1, 28, 47, 67, 98, null);
select zloz_zamowienie(2, 4, 26, 12, 67, 44, null);
select zloz_zamowienie(1, 4, 13, 11, 67, 90, null);
select zloz_zamowienie(1, 1, 10, 13, 67, 8, null);
select zloz_zamowienie(2, 3, 43, 11, 67, 40, null);
select zloz_zamowienie(1, 1, 3, 10, 67, 40, null);
select zloz_zamowienie(2, 2, 14, 3, 67, 38, null);
select zloz_zamowienie(1, 2, 27, 18, 67, 65, null);
select zloz_zamowienie(1, 3, 42, 43, 67, 25, null);
select zloz_zamowienie(2, 2, 9, 44, 67, 16, null);
select zloz_zamowienie(1, 1, 39, 5, 67, 81, null);
select zloz_zamowienie(1, 2, 23, 39, 67, 52, null);
select zloz_zamowienie(2, 4, 14, 9, 67, 85, null);
select zloz_zamowienie(1, 3, 44, 14, 67, 58, null);
select zloz_zamowienie(1, 3, 26, 34, 67, 16, null);
select zloz_zamowienie(1, 4, 20, 19, 67, 43, null);
select zloz_zamowienie(1, 3, 30, 48, 67, 11, null);
select zloz_zamowienie(2, 2, 14, 50, 68, 34, null);
select zloz_zamowienie(2, 2, 37, 27, 68, 37, null);
select zloz_zamowienie(2, 1, 24, 18, 68, 98, null);
select zloz_zamowienie(1, 1, 10, 50, 68, 90, null);
select zloz_zamowienie(2, 1, 25, 43, 68, 77, null);
select zloz_zamowienie(1, 2, 33, 9, 68, 95, null);
select zloz_zamowienie(2, 4, 17, 37, 68, 81, null);
select zloz_zamowienie(1, 3, 39, 40, 68, 35, null);
select zloz_zamowienie(2, 4, 22, 5, 68, 9, null);
select zloz_zamowienie(2, 1, 22, 37, 68, 40, null);
select zloz_zamowienie(1, 3, 6, 49, 68, 65, null);
select zloz_zamowienie(2, 2, 23, 6, 68, 61, null);
select zloz_zamowienie(1, 1, 48, 28, 68, 86, null);
select zloz_zamowienie(1, 3, 12, 22, 68, 69, null);
select zloz_zamowienie(2, 4, 50, 11, 68, 23, null);
select zloz_zamowienie(2, 1, 23, 43, 68, 80, null);
select zloz_zamowienie(1, 2, 28, 29, 68, 82, null);
select zloz_zamowienie(1, 3, 30, 21, 68, 1, null);
select zloz_zamowienie(1, 4, 47, 2, 68, 54, null);
select zloz_zamowienie(1, 3, 17, 48, 68, 17, null);
select zloz_zamowienie(1, 1, 40, 3, 69, 35, null);
select zloz_zamowienie(2, 4, 34, 24, 69, 73, null);
select zloz_zamowienie(1, 4, 9, 11, 69, 55, null);
select zloz_zamowienie(2, 2, 25, 12, 69, 75, null);
select zloz_zamowienie(2, 3, 16, 43, 69, 100, null);
select zloz_zamowienie(1, 2, 43, 29, 69, 71, null);
select zloz_zamowienie(2, 1, 18, 40, 69, 4, null);
select zloz_zamowienie(2, 4, 42, 36, 69, 100, null);
select zloz_zamowienie(1, 2, 3, 21, 69, 18, null);
select zloz_zamowienie(2, 3, 5, 19, 69, 50, null);
select zloz_zamowienie(2, 2, 29, 50, 69, 70, null);
select zloz_zamowienie(1, 1, 28, 34, 69, 67, null);
select zloz_zamowienie(2, 2, 21, 23, 69, 13, null);
select zloz_zamowienie(1, 2, 42, 41, 69, 56, null);
select zloz_zamowienie(1, 4, 18, 23, 69, 79, null);
select zloz_zamowienie(1, 2, 46, 33, 69, 31, null);
select zloz_zamowienie(1, 1, 42, 21, 69, 54, null);
select zloz_zamowienie(2, 3, 2, 45, 69, 14, null);
select zloz_zamowienie(1, 3, 49, 21, 69, 30, null);
select zloz_zamowienie(2, 3, 29, 39, 69, 49, null);
select zloz_zamowienie(2, 2, 14, 47, 70, 23, null);
select zloz_zamowienie(1, 4, 9, 20, 70, 1, null);
select zloz_zamowienie(1, 4, 25, 15, 70, 63, null);
select zloz_zamowienie(2, 3, 20, 13, 70, 96, null);
select zloz_zamowienie(2, 3, 32, 13, 70, 88, null);
select zloz_zamowienie(2, 1, 24, 43, 70, 18, null);
select zloz_zamowienie(2, 4, 18, 1, 70, 63, null);
select zloz_zamowienie(1, 2, 7, 19, 70, 20, null);
select zloz_zamowienie(1, 2, 11, 15, 70, 98, null);
select zloz_zamowienie(1, 1, 11, 48, 70, 71, null);
select zloz_zamowienie(1, 4, 7, 12, 70, 87, null);
select zloz_zamowienie(2, 4, 22, 32, 70, 100, null);
select zloz_zamowienie(1, 4, 6, 39, 70, 23, null);
select zloz_zamowienie(2, 3, 40, 5, 70, 5, null);
select zloz_zamowienie(2, 1, 24, 33, 70, 26, null);
select zloz_zamowienie(2, 4, 46, 40, 70, 87, null);
select zloz_zamowienie(2, 4, 10, 43, 70, 9, null);
select zloz_zamowienie(1, 1, 13, 21, 70, 28, null);
select zloz_zamowienie(1, 4, 41, 48, 70, 53, null);
select zloz_zamowienie(1, 4, 14, 44, 70, 82, null);
select zloz_zamowienie(1, 1, 7, 31, 71, 29, null);
select zloz_zamowienie(1, 2, 44, 26, 71, 19, null);
select zloz_zamowienie(2, 3, 29, 18, 71, 95, null);
select zloz_zamowienie(1, 2, 36, 27, 71, 50, null);
select zloz_zamowienie(2, 2, 40, 17, 71, 81, null);
select zloz_zamowienie(2, 4, 49, 23, 71, 53, null);
select zloz_zamowienie(1, 2, 32, 8, 71, 14, null);
select zloz_zamowienie(2, 3, 47, 9, 71, 79, null);
select zloz_zamowienie(2, 2, 49, 42, 71, 34, null);
select zloz_zamowienie(1, 2, 40, 42, 71, 44, null);
select zloz_zamowienie(2, 2, 34, 1, 71, 51, null);
select zloz_zamowienie(2, 2, 3, 24, 71, 19, null);
select zloz_zamowienie(1, 2, 41, 20, 71, 77, null);
select zloz_zamowienie(2, 1, 48, 29, 71, 70, null);
select zloz_zamowienie(2, 1, 14, 17, 71, 1, null);
select zloz_zamowienie(2, 4, 11, 10, 71, 31, null);
select zloz_zamowienie(2, 4, 40, 29, 71, 90, null);
select zloz_zamowienie(1, 4, 32, 28, 71, 2, null);
select zloz_zamowienie(2, 1, 20, 40, 71, 98, null);
select zloz_zamowienie(1, 1, 33, 23, 71, 64, null);
select zloz_zamowienie(2, 1, 9, 38, 72, 17, null);
select zloz_zamowienie(1, 2, 41, 49, 72, 48, null);
select zloz_zamowienie(1, 1, 50, 48, 72, 5, null);
select zloz_zamowienie(2, 1, 26, 32, 72, 91, null);
select zloz_zamowienie(2, 3, 37, 40, 72, 63, null);
select zloz_zamowienie(2, 3, 39, 23, 72, 39, null);
select zloz_zamowienie(1, 4, 22, 14, 72, 91, null);
select zloz_zamowienie(2, 3, 15, 18, 72, 67, null);
select zloz_zamowienie(2, 2, 15, 5, 72, 5, null);
select zloz_zamowienie(1, 2, 46, 40, 72, 10, null);
select zloz_zamowienie(1, 1, 33, 47, 72, 36, null);
select zloz_zamowienie(2, 3, 49, 40, 72, 28, null);
select zloz_zamowienie(1, 1, 37, 14, 72, 13, null);
select zloz_zamowienie(1, 2, 24, 4, 72, 55, null);
select zloz_zamowienie(1, 4, 46, 38, 72, 78, null);
select zloz_zamowienie(2, 2, 13, 8, 72, 14, null);
select zloz_zamowienie(2, 4, 9, 21, 72, 68, null);
select zloz_zamowienie(2, 4, 25, 16, 72, 26, null);
select zloz_zamowienie(2, 1, 12, 13, 72, 71, null);
select zloz_zamowienie(1, 3, 45, 35, 72, 28, null);
select zloz_zamowienie(2, 3, 38, 39, 73, 35, null);
select zloz_zamowienie(2, 3, 27, 25, 73, 63, null);
select zloz_zamowienie(2, 4, 31, 20, 73, 30, null);
select zloz_zamowienie(1, 4, 10, 25, 73, 69, null);
select zloz_zamowienie(2, 4, 15, 32, 73, 6, null);
select zloz_zamowienie(2, 2, 33, 16, 73, 16, null);
select zloz_zamowienie(1, 1, 36, 5, 73, 97, null);
select zloz_zamowienie(1, 3, 18, 12, 73, 5, null);
select zloz_zamowienie(2, 4, 27, 19, 73, 25, null);
select zloz_zamowienie(2, 1, 41, 33, 73, 72, null);
select zloz_zamowienie(1, 1, 26, 9, 73, 100, null);
select zloz_zamowienie(1, 4, 23, 14, 73, 8, null);
select zloz_zamowienie(1, 4, 44, 10, 73, 87, null);
select zloz_zamowienie(2, 2, 29, 46, 73, 94, null);
select zloz_zamowienie(2, 1, 41, 48, 73, 18, null);
select zloz_zamowienie(1, 3, 13, 32, 73, 94, null);
select zloz_zamowienie(1, 3, 40, 49, 73, 5, null);
select zloz_zamowienie(1, 3, 11, 24, 73, 81, null);
select zloz_zamowienie(1, 4, 43, 1, 73, 31, null);
select zloz_zamowienie(1, 4, 1, 10, 73, 100, null);
select zloz_zamowienie(1, 1, 27, 7, 74, 10, null);
select zloz_zamowienie(2, 1, 1, 3, 74, 60, null);
select zloz_zamowienie(2, 3, 16, 32, 74, 37, null);
select zloz_zamowienie(2, 4, 40, 19, 74, 3, null);
select zloz_zamowienie(1, 2, 12, 48, 74, 41, null);
select zloz_zamowienie(2, 1, 50, 23, 74, 26, null);
select zloz_zamowienie(1, 4, 7, 35, 74, 49, null);
select zloz_zamowienie(2, 3, 50, 31, 74, 53, null);
select zloz_zamowienie(2, 4, 18, 46, 74, 14, null);
select zloz_zamowienie(1, 4, 23, 26, 74, 82, null);
select zloz_zamowienie(2, 4, 35, 12, 74, 99, null);
select zloz_zamowienie(1, 4, 34, 32, 74, 46, null);
select zloz_zamowienie(2, 4, 38, 49, 74, 8, null);
select zloz_zamowienie(1, 1, 49, 47, 74, 26, null);
select zloz_zamowienie(1, 1, 4, 34, 74, 13, null);
select zloz_zamowienie(2, 1, 14, 27, 74, 64, null);
select zloz_zamowienie(1, 2, 46, 4, 74, 15, null);
select zloz_zamowienie(2, 4, 16, 33, 74, 31, null);
select zloz_zamowienie(2, 1, 48, 36, 74, 44, null);
select zloz_zamowienie(2, 4, 13, 12, 74, 57, null);
select zloz_zamowienie(1, 1, 37, 5, 75, 32, null);
select zloz_zamowienie(1, 4, 33, 3, 75, 79, null);
select zloz_zamowienie(2, 2, 24, 26, 75, 83, null);
select zloz_zamowienie(1, 1, 9, 37, 75, 79, null);
select zloz_zamowienie(2, 4, 10, 32, 75, 16, null);
select zloz_zamowienie(1, 4, 6, 47, 75, 72, null);
select zloz_zamowienie(1, 2, 28, 22, 75, 50, null);
select zloz_zamowienie(1, 2, 5, 31, 75, 29, null);
select zloz_zamowienie(1, 4, 22, 33, 75, 78, null);
select zloz_zamowienie(2, 2, 24, 3, 75, 63, null);
select zloz_zamowienie(2, 4, 43, 41, 75, 97, null);
select zloz_zamowienie(2, 3, 39, 37, 75, 50, null);
select zloz_zamowienie(1, 4, 26, 40, 75, 73, null);
select zloz_zamowienie(1, 2, 17, 8, 75, 13, null);
select zloz_zamowienie(1, 4, 1, 11, 75, 16, null);
select zloz_zamowienie(1, 4, 37, 16, 75, 95, null);
select zloz_zamowienie(2, 1, 38, 18, 75, 72, null);
select zloz_zamowienie(1, 2, 22, 31, 75, 37, null);
select zloz_zamowienie(1, 1, 47, 31, 75, 43, null);
select zloz_zamowienie(2, 4, 27, 3, 75, 41, null);
select zloz_zamowienie(1, 4, 40, 11, 76, 70, null);
select zloz_zamowienie(1, 3, 16, 26, 76, 68, null);
select zloz_zamowienie(2, 4, 4, 23, 76, 48, null);
select zloz_zamowienie(1, 3, 22, 36, 76, 35, null);
select zloz_zamowienie(1, 4, 45, 36, 76, 50, null);
select zloz_zamowienie(1, 3, 33, 21, 76, 63, null);
select zloz_zamowienie(1, 4, 8, 34, 76, 34, null);
select zloz_zamowienie(1, 3, 39, 11, 76, 96, null);
select zloz_zamowienie(2, 1, 7, 34, 76, 36, null);
select zloz_zamowienie(1, 2, 24, 2, 76, 74, null);
select zloz_zamowienie(2, 4, 13, 34, 76, 1, null);
select zloz_zamowienie(1, 3, 50, 46, 76, 24, null);
select zloz_zamowienie(2, 1, 15, 7, 76, 88, null);
select zloz_zamowienie(2, 1, 23, 43, 76, 16, null);
select zloz_zamowienie(2, 1, 44, 30, 76, 17, null);
select zloz_zamowienie(2, 1, 19, 44, 76, 29, null);
select zloz_zamowienie(1, 1, 23, 50, 76, 42, null);
select zloz_zamowienie(2, 1, 1, 25, 76, 53, null);
select zloz_zamowienie(2, 4, 38, 19, 76, 25, null);
select zloz_zamowienie(1, 3, 10, 9, 76, 17, null);
select zloz_zamowienie(2, 1, 19, 50, 77, 23, null);
select zloz_zamowienie(1, 4, 10, 16, 77, 25, null);
select zloz_zamowienie(2, 1, 7, 19, 77, 19, null);
select zloz_zamowienie(1, 2, 13, 11, 77, 37, null);
select zloz_zamowienie(1, 4, 36, 27, 77, 34, null);
select zloz_zamowienie(1, 1, 3, 1, 77, 25, null);
select zloz_zamowienie(2, 1, 11, 41, 77, 94, null);
select zloz_zamowienie(2, 4, 15, 14, 77, 7, null);
select zloz_zamowienie(2, 2, 17, 44, 77, 22, null);
select zloz_zamowienie(2, 1, 47, 7, 77, 91, null);
select zloz_zamowienie(1, 4, 14, 32, 77, 75, null);
select zloz_zamowienie(2, 4, 22, 35, 77, 70, null);
select zloz_zamowienie(1, 2, 43, 7, 77, 88, null);
select zloz_zamowienie(2, 1, 10, 5, 77, 34, null);
select zloz_zamowienie(1, 4, 22, 39, 77, 27, null);
select zloz_zamowienie(2, 1, 4, 1, 77, 20, null);
select zloz_zamowienie(1, 2, 8, 39, 77, 36, null);
select zloz_zamowienie(2, 3, 48, 20, 77, 2, null);
select zloz_zamowienie(2, 4, 7, 1, 77, 29, null);
select zloz_zamowienie(2, 4, 47, 25, 77, 11, null);
select zloz_zamowienie(2, 3, 27, 24, 78, 30, null);
select zloz_zamowienie(1, 2, 2, 44, 78, 95, null);
select zloz_zamowienie(1, 4, 14, 43, 78, 75, null);
select zloz_zamowienie(2, 3, 9, 29, 78, 64, null);
select zloz_zamowienie(2, 4, 35, 44, 78, 94, null);
select zloz_zamowienie(1, 2, 40, 24, 78, 54, null);
select zloz_zamowienie(2, 3, 1, 41, 78, 4, null);
select zloz_zamowienie(1, 4, 2, 14, 78, 18, null);
select zloz_zamowienie(2, 3, 32, 16, 78, 60, null);
select zloz_zamowienie(1, 4, 18, 5, 78, 65, null);
select zloz_zamowienie(2, 2, 42, 20, 78, 13, null);
select zloz_zamowienie(1, 1, 42, 14, 78, 21, null);
select zloz_zamowienie(2, 4, 41, 10, 78, 6, null);
select zloz_zamowienie(2, 2, 29, 8, 78, 91, null);
select zloz_zamowienie(1, 2, 42, 18, 78, 16, null);
select zloz_zamowienie(2, 1, 7, 16, 78, 68, null);
select zloz_zamowienie(2, 2, 35, 20, 78, 53, null);
select zloz_zamowienie(1, 2, 46, 39, 78, 54, null);
select zloz_zamowienie(2, 1, 13, 26, 78, 16, null);
select zloz_zamowienie(2, 1, 29, 34, 78, 62, null);
select zloz_zamowienie(1, 2, 36, 27, 79, 61, null);
select zloz_zamowienie(1, 4, 19, 48, 79, 89, null);
select zloz_zamowienie(2, 3, 45, 37, 79, 82, null);
select zloz_zamowienie(2, 2, 24, 12, 79, 85, null);
select zloz_zamowienie(2, 2, 2, 5, 79, 8, null);
select zloz_zamowienie(1, 2, 30, 42, 79, 58, null);
select zloz_zamowienie(1, 4, 40, 31, 79, 72, null);
select zloz_zamowienie(1, 4, 27, 13, 79, 100, null);
select zloz_zamowienie(2, 4, 3, 38, 79, 23, null);
select zloz_zamowienie(1, 4, 15, 47, 79, 84, null);
select zloz_zamowienie(2, 1, 23, 24, 79, 39, null);
select zloz_zamowienie(1, 2, 32, 7, 79, 76, null);
select zloz_zamowienie(2, 1, 46, 24, 79, 53, null);
select zloz_zamowienie(1, 2, 43, 8, 79, 27, null);
select zloz_zamowienie(2, 3, 6, 7, 79, 82, null);
select zloz_zamowienie(1, 3, 26, 15, 79, 56, null);
select zloz_zamowienie(2, 1, 37, 28, 79, 86, null);
select zloz_zamowienie(1, 2, 8, 38, 79, 85, null);
select zloz_zamowienie(2, 4, 33, 42, 79, 32, null);
select zloz_zamowienie(2, 1, 27, 30, 79, 94, null);
select zloz_zamowienie(2, 4, 39, 45, 80, 48, null);
select zloz_zamowienie(1, 2, 29, 31, 80, 65, null);
select zloz_zamowienie(1, 2, 1, 13, 80, 13, null);
select zloz_zamowienie(2, 1, 47, 5, 80, 65, null);
select zloz_zamowienie(1, 4, 14, 33, 80, 11, null);
select zloz_zamowienie(1, 1, 22, 40, 80, 29, null);
select zloz_zamowienie(2, 3, 4, 28, 80, 42, null);
select zloz_zamowienie(1, 4, 49, 36, 80, 73, null);
select zloz_zamowienie(1, 3, 3, 25, 80, 91, null);
select zloz_zamowienie(2, 1, 45, 5, 80, 32, null);
select zloz_zamowienie(1, 3, 39, 43, 80, 52, null);
select zloz_zamowienie(1, 1, 18, 50, 80, 85, null);
select zloz_zamowienie(1, 4, 15, 22, 80, 62, null);
select zloz_zamowienie(2, 4, 35, 12, 80, 95, null);
select zloz_zamowienie(1, 1, 43, 41, 80, 51, null);
select zloz_zamowienie(2, 2, 33, 40, 80, 55, null);
select zloz_zamowienie(1, 3, 47, 33, 80, 8, null);
select zloz_zamowienie(2, 2, 41, 18, 80, 42, null);
select zloz_zamowienie(1, 4, 13, 37, 80, 98, null);
select zloz_zamowienie(2, 4, 37, 44, 80, 25, null);
select zloz_zamowienie(1, 3, 36, 11, 81, 34, null);
select zloz_zamowienie(1, 1, 25, 14, 81, 86, null);
select zloz_zamowienie(1, 4, 22, 16, 81, 99, null);
select zloz_zamowienie(2, 1, 36, 46, 81, 84, null);
select zloz_zamowienie(2, 3, 20, 29, 81, 78, null);
select zloz_zamowienie(1, 3, 47, 27, 81, 65, null);
select zloz_zamowienie(2, 2, 46, 49, 81, 60, null);
select zloz_zamowienie(1, 2, 9, 47, 81, 24, null);
select zloz_zamowienie(2, 3, 13, 39, 81, 73, null);
select zloz_zamowienie(1, 1, 26, 19, 81, 87, null);
select zloz_zamowienie(1, 1, 4, 28, 81, 89, null);
select zloz_zamowienie(1, 3, 42, 35, 81, 60, null);
select zloz_zamowienie(1, 4, 46, 13, 81, 33, null);
select zloz_zamowienie(2, 4, 45, 4, 81, 26, null);
select zloz_zamowienie(2, 4, 50, 24, 81, 40, null);
select zloz_zamowienie(2, 1, 31, 10, 81, 9, null);
select zloz_zamowienie(2, 1, 30, 38, 81, 45, null);
select zloz_zamowienie(2, 1, 28, 50, 81, 26, null);
select zloz_zamowienie(2, 3, 20, 14, 81, 24, null);
select zloz_zamowienie(1, 4, 45, 3, 81, 78, null);
select zloz_zamowienie(2, 3, 36, 44, 82, 84, null);
select zloz_zamowienie(1, 1, 14, 23, 82, 60, null);
select zloz_zamowienie(2, 4, 7, 37, 82, 87, null);
select zloz_zamowienie(1, 1, 47, 46, 82, 57, null);
select zloz_zamowienie(2, 1, 49, 22, 82, 63, null);
select zloz_zamowienie(2, 2, 34, 40, 82, 6, null);
select zloz_zamowienie(1, 4, 6, 29, 82, 19, null);
select zloz_zamowienie(2, 1, 10, 41, 82, 31, null);
select zloz_zamowienie(2, 4, 15, 35, 82, 8, null);
select zloz_zamowienie(2, 1, 37, 12, 82, 9, null);
select zloz_zamowienie(2, 4, 23, 41, 82, 30, null);
select zloz_zamowienie(1, 1, 15, 28, 82, 84, null);
select zloz_zamowienie(2, 1, 26, 28, 82, 53, null);
select zloz_zamowienie(1, 1, 13, 33, 82, 85, null);
select zloz_zamowienie(1, 1, 24, 27, 82, 61, null);
select zloz_zamowienie(2, 1, 44, 9, 82, 99, null);
select zloz_zamowienie(2, 2, 17, 26, 82, 43, null);
select zloz_zamowienie(2, 3, 10, 36, 82, 43, null);
select zloz_zamowienie(1, 4, 6, 39, 82, 43, null);
select zloz_zamowienie(2, 2, 20, 22, 82, 90, null);
select zloz_zamowienie(1, 3, 19, 27, 83, 28, null);
select zloz_zamowienie(1, 1, 29, 9, 83, 92, null);
select zloz_zamowienie(1, 1, 45, 13, 83, 17, null);
select zloz_zamowienie(2, 2, 11, 42, 83, 22, null);
select zloz_zamowienie(2, 3, 49, 22, 83, 99, null);
select zloz_zamowienie(2, 1, 33, 8, 83, 27, null);
select zloz_zamowienie(2, 1, 30, 29, 83, 85, null);
select zloz_zamowienie(1, 3, 9, 11, 83, 57, null);
select zloz_zamowienie(2, 2, 37, 21, 83, 75, null);
select zloz_zamowienie(2, 2, 10, 40, 83, 31, null);
select zloz_zamowienie(1, 3, 38, 44, 83, 93, null);
select zloz_zamowienie(1, 4, 37, 41, 83, 60, null);
select zloz_zamowienie(2, 3, 36, 34, 83, 56, null);
select zloz_zamowienie(1, 2, 32, 19, 83, 20, null);
select zloz_zamowienie(2, 1, 7, 2, 83, 48, null);
select zloz_zamowienie(1, 2, 34, 47, 83, 35, null);
select zloz_zamowienie(1, 4, 31, 29, 83, 40, null);
select zloz_zamowienie(2, 2, 49, 35, 83, 73, null);
select zloz_zamowienie(1, 3, 40, 6, 83, 50, null);
select zloz_zamowienie(2, 4, 29, 5, 83, 31, null);
select zloz_zamowienie(2, 2, 47, 50, 84, 15, null);
select zloz_zamowienie(1, 1, 20, 42, 84, 100, null);
select zloz_zamowienie(1, 4, 4, 47, 84, 26, null);
select zloz_zamowienie(1, 1, 42, 25, 84, 25, null);
select zloz_zamowienie(2, 4, 24, 2, 84, 40, null);
select zloz_zamowienie(2, 1, 12, 22, 84, 12, null);
select zloz_zamowienie(1, 4, 2, 45, 84, 34, null);
select zloz_zamowienie(1, 3, 42, 30, 84, 71, null);
select zloz_zamowienie(1, 1, 38, 15, 84, 58, null);
select zloz_zamowienie(1, 1, 35, 15, 84, 100, null);
select zloz_zamowienie(1, 3, 16, 48, 84, 94, null);
select zloz_zamowienie(2, 2, 6, 17, 84, 43, null);
select zloz_zamowienie(2, 2, 4, 19, 84, 25, null);
select zloz_zamowienie(1, 3, 38, 5, 84, 75, null);
select zloz_zamowienie(1, 3, 42, 44, 84, 44, null);
select zloz_zamowienie(2, 1, 24, 17, 84, 85, null);
select zloz_zamowienie(2, 2, 32, 23, 84, 25, null);
select zloz_zamowienie(1, 3, 29, 11, 84, 49, null);
select zloz_zamowienie(2, 1, 10, 21, 84, 42, null);
select zloz_zamowienie(1, 2, 27, 41, 84, 5, null);
select zloz_zamowienie(1, 1, 49, 41, 85, 10, null);
select zloz_zamowienie(2, 3, 21, 16, 85, 93, null);
select zloz_zamowienie(2, 3, 13, 15, 85, 49, null);
select zloz_zamowienie(2, 3, 48, 8, 85, 100, null);
select zloz_zamowienie(1, 3, 9, 5, 85, 21, null);
select zloz_zamowienie(2, 2, 24, 10, 85, 22, null);
select zloz_zamowienie(2, 1, 50, 6, 85, 48, null);
select zloz_zamowienie(1, 3, 22, 23, 85, 70, null);
select zloz_zamowienie(1, 2, 25, 23, 85, 33, null);
select zloz_zamowienie(1, 1, 46, 30, 85, 100, null);
select zloz_zamowienie(1, 4, 30, 8, 85, 27, null);
select zloz_zamowienie(2, 4, 20, 40, 85, 100, null);
select zloz_zamowienie(2, 3, 41, 10, 85, 47, null);
select zloz_zamowienie(1, 3, 10, 24, 85, 97, null);
select zloz_zamowienie(1, 4, 12, 29, 85, 98, null);
select zloz_zamowienie(1, 3, 31, 10, 85, 44, null);
select zloz_zamowienie(1, 3, 3, 17, 85, 23, null);
select zloz_zamowienie(1, 3, 9, 22, 85, 56, null);
select zloz_zamowienie(1, 3, 9, 3, 85, 89, null);
select zloz_zamowienie(1, 3, 50, 7, 85, 89, null);
select zloz_zamowienie(2, 3, 35, 36, 86, 42, null);
select zloz_zamowienie(2, 3, 27, 15, 86, 22, null);
select zloz_zamowienie(2, 3, 41, 16, 86, 74, null);
select zloz_zamowienie(2, 1, 11, 4, 86, 9, null);
select zloz_zamowienie(2, 4, 14, 40, 86, 68, null);
select zloz_zamowienie(1, 4, 45, 39, 86, 21, null);
select zloz_zamowienie(1, 2, 40, 37, 86, 90, null);
select zloz_zamowienie(1, 4, 14, 39, 86, 12, null);
select zloz_zamowienie(1, 2, 33, 32, 86, 25, null);
select zloz_zamowienie(2, 3, 43, 37, 86, 74, null);
select zloz_zamowienie(1, 1, 17, 16, 86, 41, null);
select zloz_zamowienie(1, 3, 27, 49, 86, 46, null);
select zloz_zamowienie(2, 1, 32, 13, 86, 94, null);
select zloz_zamowienie(2, 1, 46, 43, 86, 81, null);
select zloz_zamowienie(1, 2, 19, 47, 86, 14, null);
select zloz_zamowienie(1, 3, 20, 10, 86, 76, null);
select zloz_zamowienie(2, 4, 20, 48, 86, 21, null);
select zloz_zamowienie(1, 4, 36, 8, 86, 30, null);
select zloz_zamowienie(2, 2, 30, 29, 86, 71, null);
select zloz_zamowienie(1, 1, 47, 30, 86, 42, null);
select zloz_zamowienie(1, 3, 25, 12, 87, 53, null);
select zloz_zamowienie(2, 4, 27, 12, 87, 89, null);
select zloz_zamowienie(2, 2, 40, 3, 87, 9, null);
select zloz_zamowienie(2, 1, 47, 5, 87, 89, null);
select zloz_zamowienie(2, 2, 10, 14, 87, 65, null);
select zloz_zamowienie(2, 4, 24, 44, 87, 23, null);
select zloz_zamowienie(2, 1, 16, 23, 87, 44, null);
select zloz_zamowienie(1, 2, 46, 23, 87, 73, null);
select zloz_zamowienie(1, 1, 49, 34, 87, 36, null);
select zloz_zamowienie(2, 3, 21, 32, 87, 37, null);
select zloz_zamowienie(2, 3, 4, 2, 87, 37, null);
select zloz_zamowienie(2, 2, 16, 27, 87, 83, null);
select zloz_zamowienie(1, 1, 3, 29, 87, 93, null);
select zloz_zamowienie(1, 2, 11, 50, 87, 50, null);
select zloz_zamowienie(2, 1, 7, 43, 87, 77, null);
select zloz_zamowienie(1, 2, 17, 21, 87, 84, null);
select zloz_zamowienie(2, 4, 26, 12, 87, 44, null);
select zloz_zamowienie(1, 3, 39, 10, 87, 85, null);
select zloz_zamowienie(1, 4, 11, 29, 87, 40, null);
select zloz_zamowienie(2, 2, 45, 37, 87, 92, null);
select zloz_zamowienie(1, 1, 33, 6, 88, 72, null);
select zloz_zamowienie(1, 3, 13, 46, 88, 9, null);
select zloz_zamowienie(2, 2, 11, 45, 88, 63, null);
select zloz_zamowienie(2, 2, 26, 6, 88, 73, null);
select zloz_zamowienie(1, 4, 26, 22, 88, 78, null);
select zloz_zamowienie(2, 1, 44, 43, 88, 17, null);
select zloz_zamowienie(2, 1, 1, 36, 88, 74, null);
select zloz_zamowienie(1, 2, 10, 11, 88, 83, null);
select zloz_zamowienie(1, 2, 41, 19, 88, 93, null);
select zloz_zamowienie(2, 1, 12, 18, 88, 4, null);
select zloz_zamowienie(1, 2, 27, 37, 88, 11, null);
select zloz_zamowienie(2, 4, 6, 35, 88, 8, null);
select zloz_zamowienie(1, 2, 6, 44, 88, 85, null);
select zloz_zamowienie(2, 2, 11, 1, 88, 86, null);
select zloz_zamowienie(1, 4, 3, 14, 88, 79, null);
select zloz_zamowienie(1, 3, 18, 49, 88, 61, null);
select zloz_zamowienie(2, 1, 15, 12, 88, 74, null);
select zloz_zamowienie(1, 1, 15, 40, 88, 73, null);
select zloz_zamowienie(2, 2, 21, 30, 88, 61, null);
select zloz_zamowienie(2, 3, 10, 12, 88, 80, null);
select zloz_zamowienie(1, 3, 37, 46, 89, 3, null);
select zloz_zamowienie(1, 2, 47, 16, 89, 13, null);
select zloz_zamowienie(1, 2, 28, 21, 89, 85, null);
select zloz_zamowienie(2, 4, 34, 33, 89, 75, null);
select zloz_zamowienie(1, 1, 27, 46, 89, 31, null);
select zloz_zamowienie(2, 2, 13, 44, 89, 30, null);
select zloz_zamowienie(1, 1, 41, 33, 89, 44, null);
select zloz_zamowienie(1, 1, 1, 41, 89, 62, null);
select zloz_zamowienie(2, 2, 10, 3, 89, 59, null);
select zloz_zamowienie(1, 4, 46, 16, 89, 41, null);
select zloz_zamowienie(1, 3, 37, 5, 89, 6, null);
select zloz_zamowienie(2, 1, 1, 29, 89, 77, null);
select zloz_zamowienie(2, 3, 25, 10, 89, 76, null);
select zloz_zamowienie(1, 4, 3, 20, 89, 75, null);
select zloz_zamowienie(2, 3, 28, 49, 89, 14, null);
select zloz_zamowienie(1, 2, 15, 23, 89, 9, null);
select zloz_zamowienie(2, 3, 41, 40, 89, 1, null);
select zloz_zamowienie(2, 1, 39, 21, 89, 14, null);
select zloz_zamowienie(2, 1, 22, 9, 89, 88, null);
select zloz_zamowienie(1, 3, 33, 3, 89, 88, null);
select zloz_zamowienie(1, 4, 19, 37, 90, 41, null);
select zloz_zamowienie(1, 1, 18, 8, 90, 50, null);
select zloz_zamowienie(1, 4, 31, 26, 90, 35, null);
select zloz_zamowienie(1, 3, 50, 6, 90, 52, null);
select zloz_zamowienie(1, 2, 40, 48, 90, 63, null);
select zloz_zamowienie(1, 2, 49, 41, 90, 99, null);
select zloz_zamowienie(1, 4, 6, 16, 90, 23, null);
select zloz_zamowienie(2, 1, 41, 21, 90, 66, null);
select zloz_zamowienie(1, 1, 34, 15, 90, 94, null);
select zloz_zamowienie(1, 3, 8, 23, 90, 64, null);
select zloz_zamowienie(2, 4, 2, 48, 90, 20, null);
select zloz_zamowienie(1, 4, 24, 25, 90, 99, null);
select zloz_zamowienie(2, 3, 10, 2, 90, 45, null);
select zloz_zamowienie(2, 3, 23, 39, 90, 75, null);
select zloz_zamowienie(2, 4, 16, 35, 90, 13, null);
select zloz_zamowienie(1, 1, 23, 39, 90, 19, null);
select zloz_zamowienie(2, 2, 16, 22, 90, 12, null);
select zloz_zamowienie(2, 4, 11, 20, 90, 38, null);
select zloz_zamowienie(1, 1, 16, 28, 90, 3, null);
select zloz_zamowienie(1, 3, 12, 13, 90, 76, null);
select zloz_zamowienie(2, 1, 25, 8, 91, 63, null);
select zloz_zamowienie(1, 2, 12, 42, 91, 45, null);
select zloz_zamowienie(2, 4, 47, 15, 91, 49, null);
select zloz_zamowienie(2, 2, 33, 10, 91, 31, null);
select zloz_zamowienie(2, 2, 49, 43, 91, 35, null);
select zloz_zamowienie(2, 4, 28, 45, 91, 42, null);
select zloz_zamowienie(1, 4, 4, 2, 91, 92, null);
select zloz_zamowienie(1, 2, 40, 47, 91, 76, null);
select zloz_zamowienie(2, 4, 13, 16, 91, 17, null);
select zloz_zamowienie(2, 3, 48, 44, 91, 46, null);
select zloz_zamowienie(2, 4, 25, 29, 91, 46, null);
select zloz_zamowienie(2, 3, 17, 22, 91, 26, null);
select zloz_zamowienie(2, 4, 3, 30, 91, 16, null);
select zloz_zamowienie(2, 1, 15, 33, 91, 21, null);
select zloz_zamowienie(2, 2, 32, 38, 91, 1, null);
select zloz_zamowienie(1, 1, 39, 45, 91, 93, null);
select zloz_zamowienie(2, 3, 39, 3, 91, 87, null);
select zloz_zamowienie(2, 3, 24, 10, 91, 59, null);
select zloz_zamowienie(1, 2, 7, 45, 91, 11, null);
select zloz_zamowienie(2, 2, 34, 49, 91, 73, null);
select zloz_zamowienie(2, 3, 25, 45, 92, 75, null);
select zloz_zamowienie(1, 2, 7, 20, 92, 62, null);
select zloz_zamowienie(2, 4, 6, 41, 92, 74, null);
select zloz_zamowienie(1, 3, 12, 24, 92, 79, null);
select zloz_zamowienie(1, 1, 21, 40, 92, 69, null);
select zloz_zamowienie(1, 3, 2, 20, 92, 74, null);
select zloz_zamowienie(1, 1, 43, 47, 92, 67, null);
select zloz_zamowienie(2, 1, 46, 26, 92, 95, null);
select zloz_zamowienie(2, 2, 27, 50, 92, 10, null);
select zloz_zamowienie(1, 4, 48, 28, 92, 42, null);
select zloz_zamowienie(1, 1, 5, 48, 92, 35, null);
select zloz_zamowienie(1, 4, 7, 17, 92, 1, null);
select zloz_zamowienie(2, 2, 24, 43, 92, 51, null);
select zloz_zamowienie(1, 2, 38, 25, 92, 88, null);
select zloz_zamowienie(1, 4, 19, 17, 92, 32, null);
select zloz_zamowienie(2, 2, 2, 27, 92, 89, null);
select zloz_zamowienie(2, 3, 5, 28, 92, 7, null);
select zloz_zamowienie(2, 2, 1, 15, 92, 20, null);
select zloz_zamowienie(1, 1, 34, 20, 92, 62, null);
select zloz_zamowienie(1, 4, 9, 38, 92, 89, null);
select zloz_zamowienie(2, 4, 37, 28, 93, 55, null);
select zloz_zamowienie(2, 2, 18, 16, 93, 56, null);
select zloz_zamowienie(1, 1, 50, 4, 93, 9, null);
select zloz_zamowienie(1, 1, 47, 26, 93, 73, null);
select zloz_zamowienie(2, 3, 6, 39, 93, 42, null);
select zloz_zamowienie(2, 2, 3, 14, 93, 43, null);
select zloz_zamowienie(1, 1, 30, 5, 93, 51, null);
select zloz_zamowienie(2, 3, 8, 12, 93, 82, null);
select zloz_zamowienie(2, 2, 27, 23, 93, 45, null);
select zloz_zamowienie(1, 4, 31, 14, 93, 15, null);
select zloz_zamowienie(1, 1, 47, 10, 93, 16, null);
select zloz_zamowienie(2, 1, 12, 1, 93, 38, null);
select zloz_zamowienie(1, 1, 45, 18, 93, 97, null);
select zloz_zamowienie(2, 4, 26, 21, 93, 65, null);
select zloz_zamowienie(1, 3, 48, 12, 93, 91, null);
select zloz_zamowienie(1, 3, 36, 50, 93, 55, null);
select zloz_zamowienie(2, 2, 29, 42, 93, 56, null);
select zloz_zamowienie(2, 4, 21, 17, 93, 16, null);
select zloz_zamowienie(2, 1, 1, 41, 93, 68, null);
select zloz_zamowienie(1, 3, 31, 23, 93, 84, null);
select zloz_zamowienie(2, 1, 8, 45, 94, 37, null);
select zloz_zamowienie(2, 4, 40, 49, 94, 40, null);
select zloz_zamowienie(2, 1, 38, 50, 94, 55, null);
select zloz_zamowienie(2, 4, 45, 27, 94, 73, null);
select zloz_zamowienie(1, 2, 18, 33, 94, 95, null);
select zloz_zamowienie(1, 4, 13, 42, 94, 76, null);
select zloz_zamowienie(1, 2, 44, 27, 94, 76, null);
select zloz_zamowienie(1, 2, 48, 23, 94, 48, null);
select zloz_zamowienie(1, 3, 36, 16, 94, 63, null);
select zloz_zamowienie(2, 4, 6, 50, 94, 8, null);
select zloz_zamowienie(2, 3, 26, 21, 94, 97, null);
select zloz_zamowienie(1, 4, 30, 16, 94, 55, null);
select zloz_zamowienie(1, 1, 6, 32, 94, 58, null);
select zloz_zamowienie(1, 1, 1, 18, 94, 54, null);
select zloz_zamowienie(1, 4, 30, 15, 94, 59, null);
select zloz_zamowienie(1, 3, 29, 40, 94, 17, null);
select zloz_zamowienie(1, 1, 48, 31, 94, 27, null);
select zloz_zamowienie(2, 3, 45, 31, 94, 87, null);
select zloz_zamowienie(2, 4, 45, 24, 94, 58, null);
select zloz_zamowienie(1, 4, 19, 46, 94, 61, null);
select zloz_zamowienie(2, 4, 6, 46, 95, 41, null);
select zloz_zamowienie(2, 2, 26, 21, 95, 47, null);
select zloz_zamowienie(2, 2, 40, 22, 95, 65, null);
select zloz_zamowienie(1, 4, 4, 16, 95, 47, null);
select zloz_zamowienie(1, 2, 2, 10, 95, 59, null);
select zloz_zamowienie(2, 2, 34, 50, 95, 16, null);
select zloz_zamowienie(2, 4, 31, 39, 95, 64, null);
select zloz_zamowienie(1, 2, 31, 16, 95, 65, null);
select zloz_zamowienie(1, 1, 37, 6, 95, 29, null);
select zloz_zamowienie(1, 1, 50, 4, 95, 28, null);
select zloz_zamowienie(1, 2, 18, 50, 95, 81, null);
select zloz_zamowienie(2, 3, 30, 23, 95, 82, null);
select zloz_zamowienie(2, 4, 45, 11, 95, 67, null);
select zloz_zamowienie(2, 2, 22, 25, 95, 56, null);
select zloz_zamowienie(2, 2, 12, 16, 95, 30, null);
select zloz_zamowienie(1, 2, 22, 10, 95, 55, null);
select zloz_zamowienie(2, 3, 10, 7, 95, 16, null);
select zloz_zamowienie(2, 3, 44, 40, 95, 8, null);
select zloz_zamowienie(1, 3, 13, 11, 95, 86, null);
select zloz_zamowienie(2, 4, 48, 36, 95, 67, null);
select zloz_zamowienie(1, 1, 10, 2, 96, 33, null);
select zloz_zamowienie(2, 1, 5, 40, 96, 70, null);
select zloz_zamowienie(2, 2, 41, 13, 96, 97, null);
select zloz_zamowienie(2, 4, 1, 38, 96, 4, null);
select zloz_zamowienie(1, 4, 42, 38, 96, 61, null);
select zloz_zamowienie(1, 1, 5, 35, 96, 56, null);
select zloz_zamowienie(2, 4, 7, 23, 96, 14, null);
select zloz_zamowienie(2, 1, 43, 26, 96, 93, null);
select zloz_zamowienie(1, 3, 27, 29, 96, 76, null);
select zloz_zamowienie(2, 3, 23, 44, 96, 3, null);
select zloz_zamowienie(1, 1, 3, 15, 96, 51, null);
select zloz_zamowienie(1, 3, 38, 48, 96, 46, null);
select zloz_zamowienie(1, 1, 30, 6, 96, 29, null);
select zloz_zamowienie(1, 1, 40, 30, 96, 30, null);
select zloz_zamowienie(2, 3, 23, 42, 96, 80, null);
select zloz_zamowienie(1, 4, 39, 2, 96, 10, null);
select zloz_zamowienie(2, 4, 18, 23, 96, 62, null);
select zloz_zamowienie(2, 1, 29, 20, 96, 99, null);
select zloz_zamowienie(2, 3, 50, 28, 96, 60, null);
select zloz_zamowienie(2, 4, 45, 21, 96, 53, null);
select zloz_zamowienie(2, 4, 1, 2, 97, 81, null);
select zloz_zamowienie(2, 4, 48, 47, 97, 10, null);
select zloz_zamowienie(2, 1, 44, 46, 97, 82, null);
select zloz_zamowienie(1, 4, 15, 45, 97, 58, null);
select zloz_zamowienie(1, 3, 43, 24, 97, 13, null);
select zloz_zamowienie(1, 4, 14, 49, 97, 6, null);
select zloz_zamowienie(2, 3, 47, 13, 97, 100, null);
select zloz_zamowienie(2, 2, 43, 34, 97, 46, null);
select zloz_zamowienie(1, 4, 5, 8, 97, 99, null);
select zloz_zamowienie(1, 1, 18, 19, 97, 53, null);
select zloz_zamowienie(2, 3, 34, 12, 97, 51, null);
select zloz_zamowienie(2, 2, 9, 41, 97, 77, null);
select zloz_zamowienie(1, 2, 49, 13, 97, 8, null);
select zloz_zamowienie(1, 3, 40, 20, 97, 22, null);
select zloz_zamowienie(1, 2, 12, 18, 97, 59, null);
select zloz_zamowienie(1, 1, 7, 29, 97, 3, null);
select zloz_zamowienie(1, 4, 17, 21, 97, 90, null);
select zloz_zamowienie(1, 2, 20, 13, 97, 32, null);
select zloz_zamowienie(1, 2, 15, 6, 97, 24, null);
select zloz_zamowienie(2, 3, 37, 41, 97, 17, null);
select zloz_zamowienie(1, 4, 48, 28, 98, 38, null);
select zloz_zamowienie(2, 1, 45, 16, 98, 81, null);
select zloz_zamowienie(2, 4, 23, 16, 98, 60, null);
select zloz_zamowienie(1, 2, 45, 34, 98, 51, null);
select zloz_zamowienie(2, 1, 48, 12, 98, 89, null);
select zloz_zamowienie(1, 4, 31, 16, 98, 11, null);
select zloz_zamowienie(1, 1, 6, 42, 98, 43, null);
select zloz_zamowienie(1, 3, 49, 11, 98, 50, null);
select zloz_zamowienie(2, 1, 4, 31, 98, 91, null);
select zloz_zamowienie(2, 4, 7, 42, 98, 28, null);
select zloz_zamowienie(2, 1, 35, 22, 98, 82, null);
select zloz_zamowienie(2, 2, 30, 31, 98, 24, null);
select zloz_zamowienie(2, 1, 14, 7, 98, 29, null);
select zloz_zamowienie(2, 1, 2, 20, 98, 33, null);
select zloz_zamowienie(2, 2, 48, 38, 98, 15, null);
select zloz_zamowienie(1, 4, 28, 46, 98, 78, null);
select zloz_zamowienie(1, 4, 37, 28, 98, 66, null);
select zloz_zamowienie(2, 3, 48, 5, 98, 33, null);
select zloz_zamowienie(2, 1, 40, 18, 98, 83, null);
select zloz_zamowienie(2, 4, 25, 34, 98, 2, null);
select zloz_zamowienie(2, 1, 12, 15, 99, 68, null);
select zloz_zamowienie(1, 1, 13, 15, 99, 37, null);
select zloz_zamowienie(1, 3, 41, 8, 99, 31, null);
select zloz_zamowienie(2, 3, 20, 14, 99, 53, null);
select zloz_zamowienie(2, 2, 47, 16, 99, 53, null);
select zloz_zamowienie(2, 2, 15, 32, 99, 37, null);
select zloz_zamowienie(1, 4, 27, 35, 99, 80, null);
select zloz_zamowienie(1, 1, 13, 23, 99, 76, null);
select zloz_zamowienie(2, 4, 10, 2, 99, 14, null);
select zloz_zamowienie(2, 4, 20, 16, 99, 24, null);
select zloz_zamowienie(2, 3, 17, 18, 99, 13, null);
select zloz_zamowienie(1, 1, 15, 16, 99, 23, null);
select zloz_zamowienie(2, 2, 43, 19, 99, 1, null);
select zloz_zamowienie(2, 4, 34, 36, 99, 65, null);
select zloz_zamowienie(2, 3, 15, 11, 99, 52, null);
select zloz_zamowienie(1, 1, 8, 11, 99, 11, null);
select zloz_zamowienie(1, 2, 19, 1, 99, 69, null);
select zloz_zamowienie(1, 2, 5, 35, 99, 19, null);
select zloz_zamowienie(1, 2, 27, 37, 99, 55, null);
select zloz_zamowienie(2, 2, 46, 13, 99, 42, null);
select zloz_zamowienie(2, 3, 18, 3, 100, 22, null);
select zloz_zamowienie(1, 4, 38, 36, 100, 27, null);
select zloz_zamowienie(2, 3, 24, 6, 100, 61, null);
select zloz_zamowienie(2, 1, 11, 21, 100, 99, null);
select zloz_zamowienie(2, 4, 39, 12, 100, 8, null);
select zloz_zamowienie(2, 3, 45, 36, 100, 65, null);
select zloz_zamowienie(1, 1, 31, 32, 100, 49, null);
select zloz_zamowienie(2, 2, 16, 7, 100, 69, null);
select zloz_zamowienie(1, 2, 10, 5, 100, 14, null);
select zloz_zamowienie(1, 2, 43, 48, 100, 24, null);
select zloz_zamowienie(1, 1, 27, 47, 100, 91, null);
select zloz_zamowienie(2, 3, 24, 46, 100, 73, null);
select zloz_zamowienie(1, 2, 8, 22, 100, 70, null);
select zloz_zamowienie(1, 2, 18, 49, 100, 72, null);
select zloz_zamowienie(1, 4, 23, 3, 100, 56, null);
select zloz_zamowienie(1, 1, 6, 9, 100, 20, null);
select zloz_zamowienie(1, 1, 37, 4, 100, 99, null);
select zloz_zamowienie(2, 2, 22, 40, 100, 98, null);
select zloz_zamowienie(1, 3, 3, 31, 100, 59, null);
select zloz_zamowienie(2, 2, 37, 38, 100, 34, null);
select wloz_paczke_klient(1, 1);
select wloz_paczke_klient(1, 2);
select wloz_paczke_klient(1, 3);
select wloz_paczke_klient(1, 4);
select wloz_paczke_klient(1, 5);
select wloz_paczke_klient(1, 6);
select wloz_paczke_klient(1, 7);
select wloz_paczke_klient(1, 8);
select wloz_paczke_klient(1, 9);
select wloz_paczke_klient(1, 10);
select wloz_paczke_klient(1, 11);
select wloz_paczke_klient(1, 12);
select wloz_paczke_klient(1, 13);
select wloz_paczke_klient(1, 14);
select wloz_paczke_klient(1, 15);
select wloz_paczke_klient(1, 16);
select wloz_paczke_klient(1, 17);
select wloz_paczke_klient(1, 18);
select wloz_paczke_klient(1, 19);
select wloz_paczke_klient(1, 20);
select wloz_paczke_klient(2, 21);
select wloz_paczke_klient(2, 22);
select wloz_paczke_klient(2, 23);
select wloz_paczke_klient(2, 24);
select wloz_paczke_klient(2, 25);
select wloz_paczke_klient(2, 26);
select wloz_paczke_klient(2, 27);
select wloz_paczke_klient(2, 28);
select wloz_paczke_klient(2, 29);
select wloz_paczke_klient(2, 30);
select wloz_paczke_klient(2, 31);
select wloz_paczke_klient(2, 32);
select wloz_paczke_klient(2, 33);
select wloz_paczke_klient(2, 34);
select wloz_paczke_klient(2, 35);
select wloz_paczke_klient(2, 36);
select wloz_paczke_klient(2, 37);
select wloz_paczke_klient(2, 38);
select wloz_paczke_klient(2, 39);
select wloz_paczke_klient(2, 40);
select wloz_paczke_klient(3, 41);
select wloz_paczke_klient(3, 42);
select wloz_paczke_klient(3, 43);
select wloz_paczke_klient(3, 44);
select wloz_paczke_klient(3, 45);
select wloz_paczke_klient(3, 46);
select wloz_paczke_klient(3, 47);
select wloz_paczke_klient(3, 48);
select wloz_paczke_klient(3, 49);
select wloz_paczke_klient(3, 50);
select wloz_paczke_klient(3, 51);
select wloz_paczke_klient(3, 52);
select wloz_paczke_klient(3, 53);
select wloz_paczke_klient(3, 54);
select wloz_paczke_klient(3, 55);
select wloz_paczke_klient(3, 56);
select wloz_paczke_klient(3, 57);
select wloz_paczke_klient(3, 58);
select wloz_paczke_klient(3, 59);
select wloz_paczke_klient(3, 60);
select wloz_paczke_klient(4, 61);
select wloz_paczke_klient(4, 62);
select wloz_paczke_klient(4, 63);
select wloz_paczke_klient(4, 64);
select wloz_paczke_klient(4, 65);
select wloz_paczke_klient(4, 66);
select wloz_paczke_klient(4, 67);
select wloz_paczke_klient(4, 68);
select wloz_paczke_klient(4, 69);
select wloz_paczke_klient(4, 70);
select wloz_paczke_klient(4, 71);
select wloz_paczke_klient(4, 72);
select wloz_paczke_klient(4, 73);
select wloz_paczke_klient(4, 74);
select wloz_paczke_klient(4, 75);
select wloz_paczke_klient(4, 76);
select wloz_paczke_klient(4, 77);
select wloz_paczke_klient(4, 78);
select wloz_paczke_klient(4, 79);
select wloz_paczke_klient(4, 80);
select wloz_paczke_klient(5, 81);
select wloz_paczke_klient(5, 82);
select wloz_paczke_klient(5, 83);
select wloz_paczke_klient(5, 84);
select wloz_paczke_klient(5, 85);
select wloz_paczke_klient(5, 86);
select wloz_paczke_klient(5, 87);
select wloz_paczke_klient(5, 88);
select wloz_paczke_klient(5, 89);
select wloz_paczke_klient(5, 90);
select wloz_paczke_klient(5, 91);
select wloz_paczke_klient(5, 92);
select wloz_paczke_klient(5, 93);
select wloz_paczke_klient(5, 94);
select wloz_paczke_klient(5, 95);
select wloz_paczke_klient(5, 96);
select wloz_paczke_klient(5, 97);
select wloz_paczke_klient(5, 98);
select wloz_paczke_klient(5, 99);
select wloz_paczke_klient(5, 100);
select wloz_paczke_klient(6, 101);
select wloz_paczke_klient(6, 102);
select wloz_paczke_klient(6, 103);
select wloz_paczke_klient(6, 104);
select wloz_paczke_klient(6, 105);
select wloz_paczke_klient(6, 106);
select wloz_paczke_klient(6, 107);
select wloz_paczke_klient(6, 108);
select wloz_paczke_klient(6, 109);
select wloz_paczke_klient(6, 110);
select wloz_paczke_klient(6, 111);
select wloz_paczke_klient(6, 112);
select wloz_paczke_klient(6, 113);
select wloz_paczke_klient(6, 114);
select wloz_paczke_klient(6, 115);
select wloz_paczke_klient(6, 116);
select wloz_paczke_klient(6, 117);
select wloz_paczke_klient(6, 118);
select wloz_paczke_klient(6, 119);
select wloz_paczke_klient(6, 120);
select wloz_paczke_klient(7, 121);
select wloz_paczke_klient(7, 122);
select wloz_paczke_klient(7, 123);
select wloz_paczke_klient(7, 124);
select wloz_paczke_klient(7, 125);
select wloz_paczke_klient(7, 126);
select wloz_paczke_klient(7, 127);
select wloz_paczke_klient(7, 128);
select wloz_paczke_klient(7, 129);
select wloz_paczke_klient(7, 130);
select wloz_paczke_klient(7, 131);
select wloz_paczke_klient(7, 132);
select wloz_paczke_klient(7, 133);
select wloz_paczke_klient(7, 134);
select wloz_paczke_klient(7, 135);
select wloz_paczke_klient(7, 136);
select wloz_paczke_klient(7, 137);
select wloz_paczke_klient(7, 138);
select wloz_paczke_klient(7, 139);
select wloz_paczke_klient(7, 140);
select wloz_paczke_klient(8, 141);
select wloz_paczke_klient(8, 142);
select wloz_paczke_klient(8, 143);
select wloz_paczke_klient(8, 144);
select wloz_paczke_klient(8, 145);
select wloz_paczke_klient(8, 146);
select wloz_paczke_klient(8, 147);
select wloz_paczke_klient(8, 148);
select wloz_paczke_klient(8, 149);
select wloz_paczke_klient(8, 150);
select wloz_paczke_klient(8, 151);
select wloz_paczke_klient(8, 152);
select wloz_paczke_klient(8, 153);
select wloz_paczke_klient(8, 154);
select wloz_paczke_klient(8, 155);
select wloz_paczke_klient(8, 156);
select wloz_paczke_klient(8, 157);
select wloz_paczke_klient(8, 158);
select wloz_paczke_klient(8, 159);
select wloz_paczke_klient(8, 160);
select wloz_paczke_klient(9, 161);
select wloz_paczke_klient(9, 162);
select wloz_paczke_klient(9, 163);
select wloz_paczke_klient(9, 164);
select wloz_paczke_klient(9, 165);
select wloz_paczke_klient(9, 166);
select wloz_paczke_klient(9, 167);
select wloz_paczke_klient(9, 168);
select wloz_paczke_klient(9, 169);
select wloz_paczke_klient(9, 170);
select wloz_paczke_klient(9, 171);
select wloz_paczke_klient(9, 172);
select wloz_paczke_klient(9, 173);
select wloz_paczke_klient(9, 174);
select wloz_paczke_klient(9, 175);
select wloz_paczke_klient(9, 176);
select wloz_paczke_klient(9, 177);
select wloz_paczke_klient(9, 178);
select wloz_paczke_klient(9, 179);
select wloz_paczke_klient(9, 180);
select wloz_paczke_klient(10, 181);
select wloz_paczke_klient(10, 182);
select wloz_paczke_klient(10, 183);
select wloz_paczke_klient(10, 184);
select wloz_paczke_klient(10, 185);
select wloz_paczke_klient(10, 186);
select wloz_paczke_klient(10, 187);
select wloz_paczke_klient(10, 188);
select wloz_paczke_klient(10, 189);
select wloz_paczke_klient(10, 190);
select wloz_paczke_klient(10, 191);
select wloz_paczke_klient(10, 192);
select wloz_paczke_klient(10, 193);
select wloz_paczke_klient(10, 194);
select wloz_paczke_klient(10, 195);
select wloz_paczke_klient(10, 196);
select wloz_paczke_klient(10, 197);
select wloz_paczke_klient(10, 198);
select wloz_paczke_klient(10, 199);
select wloz_paczke_klient(10, 200);
select wloz_paczke_klient(11, 201);
select wloz_paczke_klient(11, 202);
select wloz_paczke_klient(11, 203);
select wloz_paczke_klient(11, 204);
select wloz_paczke_klient(11, 205);
select wloz_paczke_klient(11, 206);
select wloz_paczke_klient(11, 207);
select wloz_paczke_klient(11, 208);
select wloz_paczke_klient(11, 209);
select wloz_paczke_klient(11, 210);
select wloz_paczke_klient(11, 211);
select wloz_paczke_klient(11, 212);
select wloz_paczke_klient(11, 213);
select wloz_paczke_klient(11, 214);
select wloz_paczke_klient(11, 215);
select wloz_paczke_klient(11, 216);
select wloz_paczke_klient(11, 217);
select wloz_paczke_klient(11, 218);
select wloz_paczke_klient(11, 219);
select wloz_paczke_klient(11, 220);
select wloz_paczke_klient(12, 221);
select wloz_paczke_klient(12, 222);
select wloz_paczke_klient(12, 223);
select wloz_paczke_klient(12, 224);
select wloz_paczke_klient(12, 225);
select wloz_paczke_klient(12, 226);
select wloz_paczke_klient(12, 227);
select wloz_paczke_klient(12, 228);
select wloz_paczke_klient(12, 229);
select wloz_paczke_klient(12, 230);
select wloz_paczke_klient(12, 231);
select wloz_paczke_klient(12, 232);
select wloz_paczke_klient(12, 233);
select wloz_paczke_klient(12, 234);
select wloz_paczke_klient(12, 235);
select wloz_paczke_klient(12, 236);
select wloz_paczke_klient(12, 237);
select wloz_paczke_klient(12, 238);
select wloz_paczke_klient(12, 239);
select wloz_paczke_klient(12, 240);
select wloz_paczke_klient(13, 241);
select wloz_paczke_klient(13, 242);
select wloz_paczke_klient(13, 243);
select wloz_paczke_klient(13, 244);
select wloz_paczke_klient(13, 245);
select wloz_paczke_klient(13, 246);
select wloz_paczke_klient(13, 247);
select wloz_paczke_klient(13, 248);
select wloz_paczke_klient(13, 249);
select wloz_paczke_klient(13, 250);
select wloz_paczke_klient(13, 251);
select wloz_paczke_klient(13, 252);
select wloz_paczke_klient(13, 253);
select wloz_paczke_klient(13, 254);
select wloz_paczke_klient(13, 255);
select wloz_paczke_klient(13, 256);
select wloz_paczke_klient(13, 257);
select wloz_paczke_klient(13, 258);
select wloz_paczke_klient(13, 259);
select wloz_paczke_klient(13, 260);
select wloz_paczke_klient(14, 261);
select wloz_paczke_klient(14, 262);
select wloz_paczke_klient(14, 263);
select wloz_paczke_klient(14, 264);
select wloz_paczke_klient(14, 265);
select wloz_paczke_klient(14, 266);
select wloz_paczke_klient(14, 267);
select wloz_paczke_klient(14, 268);
select wloz_paczke_klient(14, 269);
select wloz_paczke_klient(14, 270);
select wloz_paczke_klient(14, 271);
select wloz_paczke_klient(14, 272);
select wloz_paczke_klient(14, 273);
select wloz_paczke_klient(14, 274);
select wloz_paczke_klient(14, 275);
select wloz_paczke_klient(14, 276);
select wloz_paczke_klient(14, 277);
select wloz_paczke_klient(14, 278);
select wloz_paczke_klient(14, 279);
select wloz_paczke_klient(14, 280);
select wloz_paczke_klient(15, 281);
select wloz_paczke_klient(15, 282);
select wloz_paczke_klient(15, 283);
select wloz_paczke_klient(15, 284);
select wloz_paczke_klient(15, 285);
select wloz_paczke_klient(15, 286);
select wloz_paczke_klient(15, 287);
select wloz_paczke_klient(15, 288);
select wloz_paczke_klient(15, 289);
select wloz_paczke_klient(15, 290);
select wloz_paczke_klient(15, 291);
select wloz_paczke_klient(15, 292);
select wloz_paczke_klient(15, 293);
select wloz_paczke_klient(15, 294);
select wloz_paczke_klient(15, 295);
select wloz_paczke_klient(15, 296);
select wloz_paczke_klient(15, 297);
select wloz_paczke_klient(15, 298);
select wloz_paczke_klient(15, 299);
select wloz_paczke_klient(15, 300);
select wloz_paczke_klient(16, 301);
select wloz_paczke_klient(16, 302);
select wloz_paczke_klient(16, 303);
select wloz_paczke_klient(16, 304);
select wloz_paczke_klient(16, 305);
select wloz_paczke_klient(16, 306);
select wloz_paczke_klient(16, 307);
select wloz_paczke_klient(16, 308);
select wloz_paczke_klient(16, 309);
select wloz_paczke_klient(16, 310);
select wloz_paczke_klient(16, 311);
select wloz_paczke_klient(16, 312);
select wloz_paczke_klient(16, 313);
select wloz_paczke_klient(16, 314);
select wloz_paczke_klient(16, 315);
select wloz_paczke_klient(16, 316);
select wloz_paczke_klient(16, 317);
select wloz_paczke_klient(16, 318);
select wloz_paczke_klient(16, 319);
select wloz_paczke_klient(16, 320);
select wloz_paczke_klient(17, 321);
select wloz_paczke_klient(17, 322);
select wloz_paczke_klient(17, 323);
select wloz_paczke_klient(17, 324);
select wloz_paczke_klient(17, 325);
select wloz_paczke_klient(17, 326);
select wloz_paczke_klient(17, 327);
select wloz_paczke_klient(17, 328);
select wloz_paczke_klient(17, 329);
select wloz_paczke_klient(17, 330);
select wloz_paczke_klient(17, 331);
select wloz_paczke_klient(17, 332);
select wloz_paczke_klient(17, 333);
select wloz_paczke_klient(17, 334);
select wloz_paczke_klient(17, 335);
select wloz_paczke_klient(17, 336);
select wloz_paczke_klient(17, 337);
select wloz_paczke_klient(17, 338);
select wloz_paczke_klient(17, 339);
select wloz_paczke_klient(17, 340);
select wloz_paczke_klient(18, 341);
select wloz_paczke_klient(18, 342);
select wloz_paczke_klient(18, 343);
select wloz_paczke_klient(18, 344);
select wloz_paczke_klient(18, 345);
select wloz_paczke_klient(18, 346);
select wloz_paczke_klient(18, 347);
select wloz_paczke_klient(18, 348);
select wloz_paczke_klient(18, 349);
select wloz_paczke_klient(18, 350);
select wloz_paczke_klient(18, 351);
select wloz_paczke_klient(18, 352);
select wloz_paczke_klient(18, 353);
select wloz_paczke_klient(18, 354);
select wloz_paczke_klient(18, 355);
select wloz_paczke_klient(18, 356);
select wloz_paczke_klient(18, 357);
select wloz_paczke_klient(18, 358);
select wloz_paczke_klient(18, 359);
select wloz_paczke_klient(18, 360);
select wloz_paczke_klient(19, 361);
select wloz_paczke_klient(19, 362);
select wloz_paczke_klient(19, 363);
select wloz_paczke_klient(19, 364);
select wloz_paczke_klient(19, 365);
select wloz_paczke_klient(19, 366);
select wloz_paczke_klient(19, 367);
select wloz_paczke_klient(19, 368);
select wloz_paczke_klient(19, 369);
select wloz_paczke_klient(19, 370);
select wloz_paczke_klient(19, 371);
select wloz_paczke_klient(19, 372);
select wloz_paczke_klient(19, 373);
select wloz_paczke_klient(19, 374);
select wloz_paczke_klient(19, 375);
select wloz_paczke_klient(19, 376);
select wloz_paczke_klient(19, 377);
select wloz_paczke_klient(19, 378);
select wloz_paczke_klient(19, 379);
select wloz_paczke_klient(19, 380);
select wloz_paczke_klient(20, 381);
select wloz_paczke_klient(20, 382);
select wloz_paczke_klient(20, 383);
select wloz_paczke_klient(20, 384);
select wloz_paczke_klient(20, 385);
select wloz_paczke_klient(20, 386);
select wloz_paczke_klient(20, 387);
select wloz_paczke_klient(20, 388);
select wloz_paczke_klient(20, 389);
select wloz_paczke_klient(20, 390);
select wloz_paczke_klient(20, 391);
select wloz_paczke_klient(20, 392);
select wloz_paczke_klient(20, 393);
select wloz_paczke_klient(20, 394);
select wloz_paczke_klient(20, 395);
select wloz_paczke_klient(20, 396);
select wloz_paczke_klient(20, 397);
select wloz_paczke_klient(20, 398);
select wloz_paczke_klient(20, 399);
select wloz_paczke_klient(20, 400);
select wloz_paczke_klient(21, 401);
select wloz_paczke_klient(21, 402);
select wloz_paczke_klient(21, 403);
select wloz_paczke_klient(21, 404);
select wloz_paczke_klient(21, 405);
select wloz_paczke_klient(21, 406);
select wloz_paczke_klient(21, 407);
select wloz_paczke_klient(21, 408);
select wloz_paczke_klient(21, 409);
select wloz_paczke_klient(21, 410);
select wloz_paczke_klient(21, 411);
select wloz_paczke_klient(21, 412);
select wloz_paczke_klient(21, 413);
select wloz_paczke_klient(21, 414);
select wloz_paczke_klient(21, 415);
select wloz_paczke_klient(21, 416);
select wloz_paczke_klient(21, 417);
select wloz_paczke_klient(21, 418);
select wloz_paczke_klient(21, 419);
select wloz_paczke_klient(21, 420);
select wloz_paczke_klient(22, 421);
select wloz_paczke_klient(22, 422);
select wloz_paczke_klient(22, 423);
select wloz_paczke_klient(22, 424);
select wloz_paczke_klient(22, 425);
select wloz_paczke_klient(22, 426);
select wloz_paczke_klient(22, 427);
select wloz_paczke_klient(22, 428);
select wloz_paczke_klient(22, 429);
select wloz_paczke_klient(22, 430);
select wloz_paczke_klient(22, 431);
select wloz_paczke_klient(22, 432);
select wloz_paczke_klient(22, 433);
select wloz_paczke_klient(22, 434);
select wloz_paczke_klient(22, 435);
select wloz_paczke_klient(22, 436);
select wloz_paczke_klient(22, 437);
select wloz_paczke_klient(22, 438);
select wloz_paczke_klient(22, 439);
select wloz_paczke_klient(22, 440);
select wloz_paczke_klient(23, 441);
select wloz_paczke_klient(23, 442);
select wloz_paczke_klient(23, 443);
select wloz_paczke_klient(23, 444);
select wloz_paczke_klient(23, 445);
select wloz_paczke_klient(23, 446);
select wloz_paczke_klient(23, 447);
select wloz_paczke_klient(23, 448);
select wloz_paczke_klient(23, 449);
select wloz_paczke_klient(23, 450);
select wloz_paczke_klient(23, 451);
select wloz_paczke_klient(23, 452);
select wloz_paczke_klient(23, 453);
select wloz_paczke_klient(23, 454);
select wloz_paczke_klient(23, 455);
select wloz_paczke_klient(23, 456);
select wloz_paczke_klient(23, 457);
select wloz_paczke_klient(23, 458);
select wloz_paczke_klient(23, 459);
select wloz_paczke_klient(23, 460);
select wloz_paczke_klient(24, 461);
select wloz_paczke_klient(24, 462);
select wloz_paczke_klient(24, 463);
select wloz_paczke_klient(24, 464);
select wloz_paczke_klient(24, 465);
select wloz_paczke_klient(24, 466);
select wloz_paczke_klient(24, 467);
select wloz_paczke_klient(24, 468);
select wloz_paczke_klient(24, 469);
select wloz_paczke_klient(24, 470);
select wloz_paczke_klient(24, 471);
select wloz_paczke_klient(24, 472);
select wloz_paczke_klient(24, 473);
select wloz_paczke_klient(24, 474);
select wloz_paczke_klient(24, 475);
select wloz_paczke_klient(24, 476);
select wloz_paczke_klient(24, 477);
select wloz_paczke_klient(24, 478);
select wloz_paczke_klient(24, 479);
select wloz_paczke_klient(24, 480);
select wloz_paczke_klient(25, 481);
select wloz_paczke_klient(25, 482);
select wloz_paczke_klient(25, 483);
select wloz_paczke_klient(25, 484);
select wloz_paczke_klient(25, 485);
select wloz_paczke_klient(25, 486);
select wloz_paczke_klient(25, 487);
select wloz_paczke_klient(25, 488);
select wloz_paczke_klient(25, 489);
select wloz_paczke_klient(25, 490);
select wloz_paczke_klient(25, 491);
select wloz_paczke_klient(25, 492);
select wloz_paczke_klient(25, 493);
select wloz_paczke_klient(25, 494);
select wloz_paczke_klient(25, 495);
select wloz_paczke_klient(25, 496);
select wloz_paczke_klient(25, 497);
select wloz_paczke_klient(25, 498);
select wloz_paczke_klient(25, 499);
select wloz_paczke_klient(25, 500);
select wloz_paczke_klient(26, 501);
select wloz_paczke_klient(26, 502);
select wloz_paczke_klient(26, 503);
select wloz_paczke_klient(26, 504);
select wloz_paczke_klient(26, 505);
select wloz_paczke_klient(26, 506);
select wloz_paczke_klient(26, 507);
select wloz_paczke_klient(26, 508);
select wloz_paczke_klient(26, 509);
select wloz_paczke_klient(26, 510);
select wloz_paczke_klient(26, 511);
select wloz_paczke_klient(26, 512);
select wloz_paczke_klient(26, 513);
select wloz_paczke_klient(26, 514);
select wloz_paczke_klient(26, 515);
select wloz_paczke_klient(26, 516);
select wloz_paczke_klient(26, 517);
select wloz_paczke_klient(26, 518);
select wloz_paczke_klient(26, 519);
select wloz_paczke_klient(26, 520);
select wloz_paczke_klient(27, 521);
select wloz_paczke_klient(27, 522);
select wloz_paczke_klient(27, 523);
select wloz_paczke_klient(27, 524);
select wloz_paczke_klient(27, 525);
select wloz_paczke_klient(27, 526);
select wloz_paczke_klient(27, 527);
select wloz_paczke_klient(27, 528);
select wloz_paczke_klient(27, 529);
select wloz_paczke_klient(27, 530);
select wloz_paczke_klient(27, 531);
select wloz_paczke_klient(27, 532);
select wloz_paczke_klient(27, 533);
select wloz_paczke_klient(27, 534);
select wloz_paczke_klient(27, 535);
select wloz_paczke_klient(27, 536);
select wloz_paczke_klient(27, 537);
select wloz_paczke_klient(27, 538);
select wloz_paczke_klient(27, 539);
select wloz_paczke_klient(27, 540);
select wloz_paczke_klient(28, 541);
select wloz_paczke_klient(28, 542);
select wloz_paczke_klient(28, 543);
select wloz_paczke_klient(28, 544);
select wloz_paczke_klient(28, 545);
select wloz_paczke_klient(28, 546);
select wloz_paczke_klient(28, 547);
select wloz_paczke_klient(28, 548);
select wloz_paczke_klient(28, 549);
select wloz_paczke_klient(28, 550);
select wloz_paczke_klient(28, 551);
select wloz_paczke_klient(28, 552);
select wloz_paczke_klient(28, 553);
select wloz_paczke_klient(28, 554);
select wloz_paczke_klient(28, 555);
select wloz_paczke_klient(28, 556);
select wloz_paczke_klient(28, 557);
select wloz_paczke_klient(28, 558);
select wloz_paczke_klient(28, 559);
select wloz_paczke_klient(28, 560);
select wloz_paczke_klient(29, 561);
select wloz_paczke_klient(29, 562);
select wloz_paczke_klient(29, 563);
select wloz_paczke_klient(29, 564);
select wloz_paczke_klient(29, 565);
select wloz_paczke_klient(29, 566);
select wloz_paczke_klient(29, 567);
select wloz_paczke_klient(29, 568);
select wloz_paczke_klient(29, 569);
select wloz_paczke_klient(29, 570);
select wloz_paczke_klient(29, 571);
select wloz_paczke_klient(29, 572);
select wloz_paczke_klient(29, 573);
select wloz_paczke_klient(29, 574);
select wloz_paczke_klient(29, 575);
select wloz_paczke_klient(29, 576);
select wloz_paczke_klient(29, 577);
select wloz_paczke_klient(29, 578);
select wloz_paczke_klient(29, 579);
select wloz_paczke_klient(29, 580);
select wloz_paczke_klient(30, 581);
select wloz_paczke_klient(30, 582);
select wloz_paczke_klient(30, 583);
select wloz_paczke_klient(30, 584);
select wloz_paczke_klient(30, 585);
select wloz_paczke_klient(30, 586);
select wloz_paczke_klient(30, 587);
select wloz_paczke_klient(30, 588);
select wloz_paczke_klient(30, 589);
select wloz_paczke_klient(30, 590);
select wloz_paczke_klient(30, 591);
select wloz_paczke_klient(30, 592);
select wloz_paczke_klient(30, 593);
select wloz_paczke_klient(30, 594);
select wloz_paczke_klient(30, 595);
select wloz_paczke_klient(30, 596);
select wloz_paczke_klient(30, 597);
select wloz_paczke_klient(30, 598);
select wloz_paczke_klient(30, 599);
select wloz_paczke_klient(30, 600);
select wloz_paczke_klient(31, 601);
select wloz_paczke_klient(31, 602);
select wloz_paczke_klient(31, 603);
select wloz_paczke_klient(31, 604);
select wloz_paczke_klient(31, 605);
select wloz_paczke_klient(31, 606);
select wloz_paczke_klient(31, 607);
select wloz_paczke_klient(31, 608);
select wloz_paczke_klient(31, 609);
select wloz_paczke_klient(31, 610);
select wloz_paczke_klient(31, 611);
select wloz_paczke_klient(31, 612);
select wloz_paczke_klient(31, 613);
select wloz_paczke_klient(31, 614);
select wloz_paczke_klient(31, 615);
select wloz_paczke_klient(31, 616);
select wloz_paczke_klient(31, 617);
select wloz_paczke_klient(31, 618);
select wloz_paczke_klient(31, 619);
select wloz_paczke_klient(31, 620);
select wloz_paczke_klient(32, 621);
select wloz_paczke_klient(32, 622);
select wloz_paczke_klient(32, 623);
select wloz_paczke_klient(32, 624);
select wloz_paczke_klient(32, 625);
select wloz_paczke_klient(32, 626);
select wloz_paczke_klient(32, 627);
select wloz_paczke_klient(32, 628);
select wloz_paczke_klient(32, 629);
select wloz_paczke_klient(32, 630);
select wloz_paczke_klient(32, 631);
select wloz_paczke_klient(32, 632);
select wloz_paczke_klient(32, 633);
select wloz_paczke_klient(32, 634);
select wloz_paczke_klient(32, 635);
select wloz_paczke_klient(32, 636);
select wloz_paczke_klient(32, 637);
select wloz_paczke_klient(32, 638);
select wloz_paczke_klient(32, 639);
select wloz_paczke_klient(32, 640);
select wloz_paczke_klient(33, 641);
select wloz_paczke_klient(33, 642);
select wloz_paczke_klient(33, 643);
select wloz_paczke_klient(33, 644);
select wloz_paczke_klient(33, 645);
select wloz_paczke_klient(33, 646);
select wloz_paczke_klient(33, 647);
select wloz_paczke_klient(33, 648);
select wloz_paczke_klient(33, 649);
select wloz_paczke_klient(33, 650);
select wloz_paczke_klient(33, 651);
select wloz_paczke_klient(33, 652);
select wloz_paczke_klient(33, 653);
select wloz_paczke_klient(33, 654);
select wloz_paczke_klient(33, 655);
select wloz_paczke_klient(33, 656);
select wloz_paczke_klient(33, 657);
select wloz_paczke_klient(33, 658);
select wloz_paczke_klient(33, 659);
select wloz_paczke_klient(33, 660);
select wloz_paczke_klient(34, 661);
select wloz_paczke_klient(34, 662);
select wloz_paczke_klient(34, 663);
select wloz_paczke_klient(34, 664);
select wloz_paczke_klient(34, 665);
select wloz_paczke_klient(34, 666);
select wloz_paczke_klient(34, 667);
select wloz_paczke_klient(34, 668);
select wloz_paczke_klient(34, 669);
select wloz_paczke_klient(34, 670);
select wloz_paczke_klient(34, 671);
select wloz_paczke_klient(34, 672);
select wloz_paczke_klient(34, 673);
select wloz_paczke_klient(34, 674);
select wloz_paczke_klient(34, 675);
select wloz_paczke_klient(34, 676);
select wloz_paczke_klient(34, 677);
select wloz_paczke_klient(34, 678);
select wloz_paczke_klient(34, 679);
select wloz_paczke_klient(34, 680);
select wloz_paczke_klient(35, 681);
select wloz_paczke_klient(35, 682);
select wloz_paczke_klient(35, 683);
select wloz_paczke_klient(35, 684);
select wloz_paczke_klient(35, 685);
select wloz_paczke_klient(35, 686);
select wloz_paczke_klient(35, 687);
select wloz_paczke_klient(35, 688);
select wloz_paczke_klient(35, 689);
select wloz_paczke_klient(35, 690);
select wloz_paczke_klient(35, 691);
select wloz_paczke_klient(35, 692);
select wloz_paczke_klient(35, 693);
select wloz_paczke_klient(35, 694);
select wloz_paczke_klient(35, 695);
select wloz_paczke_klient(35, 696);
select wloz_paczke_klient(35, 697);
select wloz_paczke_klient(35, 698);
select wloz_paczke_klient(35, 699);
select wloz_paczke_klient(35, 700);
select wloz_paczke_klient(36, 701);
select wloz_paczke_klient(36, 702);
select wloz_paczke_klient(36, 703);
select wloz_paczke_klient(36, 704);
select wloz_paczke_klient(36, 705);
select wloz_paczke_klient(36, 706);
select wloz_paczke_klient(36, 707);
select wloz_paczke_klient(36, 708);
select wloz_paczke_klient(36, 709);
select wloz_paczke_klient(36, 710);
select wloz_paczke_klient(36, 711);
select wloz_paczke_klient(36, 712);
select wloz_paczke_klient(36, 713);
select wloz_paczke_klient(36, 714);
select wloz_paczke_klient(36, 715);
select wloz_paczke_klient(36, 716);
select wloz_paczke_klient(36, 717);
select wloz_paczke_klient(36, 718);
select wloz_paczke_klient(36, 719);
select wloz_paczke_klient(36, 720);
select wloz_paczke_klient(37, 721);
select wloz_paczke_klient(37, 722);
select wloz_paczke_klient(37, 723);
select wloz_paczke_klient(37, 724);
select wloz_paczke_klient(37, 725);
select wloz_paczke_klient(37, 726);
select wloz_paczke_klient(37, 727);
select wloz_paczke_klient(37, 728);
select wloz_paczke_klient(37, 729);
select wloz_paczke_klient(37, 730);
select wloz_paczke_klient(37, 731);
select wloz_paczke_klient(37, 732);
select wloz_paczke_klient(37, 733);
select wloz_paczke_klient(37, 734);
select wloz_paczke_klient(37, 735);
select wloz_paczke_klient(37, 736);
select wloz_paczke_klient(37, 737);
select wloz_paczke_klient(37, 738);
select wloz_paczke_klient(37, 739);
select wloz_paczke_klient(37, 740);
select wloz_paczke_klient(38, 741);
select wloz_paczke_klient(38, 742);
select wloz_paczke_klient(38, 743);
select wloz_paczke_klient(38, 744);
select wloz_paczke_klient(38, 745);
select wloz_paczke_klient(38, 746);
select wloz_paczke_klient(38, 747);
select wloz_paczke_klient(38, 748);
select wloz_paczke_klient(38, 749);
select wloz_paczke_klient(38, 750);
select wloz_paczke_klient(38, 751);
select wloz_paczke_klient(38, 752);
select wloz_paczke_klient(38, 753);
select wloz_paczke_klient(38, 754);
select wloz_paczke_klient(38, 755);
select wloz_paczke_klient(38, 756);
select wloz_paczke_klient(38, 757);
select wloz_paczke_klient(38, 758);
select wloz_paczke_klient(38, 759);
select wloz_paczke_klient(38, 760);
select wloz_paczke_klient(39, 761);
select wloz_paczke_klient(39, 762);
select wloz_paczke_klient(39, 763);
select wloz_paczke_klient(39, 764);
select wloz_paczke_klient(39, 765);
select wloz_paczke_klient(39, 766);
select wloz_paczke_klient(39, 767);
select wloz_paczke_klient(39, 768);
select wloz_paczke_klient(39, 769);
select wloz_paczke_klient(39, 770);
select wloz_paczke_klient(39, 771);
select wloz_paczke_klient(39, 772);
select wloz_paczke_klient(39, 773);
select wloz_paczke_klient(39, 774);
select wloz_paczke_klient(39, 775);
select wloz_paczke_klient(39, 776);
select wloz_paczke_klient(39, 777);
select wloz_paczke_klient(39, 778);
select wloz_paczke_klient(39, 779);
select wloz_paczke_klient(39, 780);
select wloz_paczke_klient(40, 781);
select wloz_paczke_klient(40, 782);
select wloz_paczke_klient(40, 783);
select wloz_paczke_klient(40, 784);
select wloz_paczke_klient(40, 785);
select wloz_paczke_klient(40, 786);
select wloz_paczke_klient(40, 787);
select wloz_paczke_klient(40, 788);
select wloz_paczke_klient(40, 789);
select wloz_paczke_klient(40, 790);
select wloz_paczke_klient(40, 791);
select wloz_paczke_klient(40, 792);
select wloz_paczke_klient(40, 793);
select wloz_paczke_klient(40, 794);
select wloz_paczke_klient(40, 795);
select wloz_paczke_klient(40, 796);
select wloz_paczke_klient(40, 797);
select wloz_paczke_klient(40, 798);
select wloz_paczke_klient(40, 799);
select wloz_paczke_klient(40, 800);
select wloz_paczke_klient(41, 801);
select wloz_paczke_klient(41, 802);
select wloz_paczke_klient(41, 803);
select wloz_paczke_klient(41, 804);
select wloz_paczke_klient(41, 805);
select wloz_paczke_klient(41, 806);
select wloz_paczke_klient(41, 807);
select wloz_paczke_klient(41, 808);
select wloz_paczke_klient(41, 809);
select wloz_paczke_klient(41, 810);
select wloz_paczke_klient(41, 811);
select wloz_paczke_klient(41, 812);
select wloz_paczke_klient(41, 813);
select wloz_paczke_klient(41, 814);
select wloz_paczke_klient(41, 815);
select wloz_paczke_klient(41, 816);
select wloz_paczke_klient(41, 817);
select wloz_paczke_klient(41, 818);
select wloz_paczke_klient(41, 819);
select wloz_paczke_klient(41, 820);
select wloz_paczke_klient(42, 821);
select wloz_paczke_klient(42, 822);
select wloz_paczke_klient(42, 823);
select wloz_paczke_klient(42, 824);
select wloz_paczke_klient(42, 825);
select wloz_paczke_klient(42, 826);
select wloz_paczke_klient(42, 827);
select wloz_paczke_klient(42, 828);
select wloz_paczke_klient(42, 829);
select wloz_paczke_klient(42, 830);
select wloz_paczke_klient(42, 831);
select wloz_paczke_klient(42, 832);
select wloz_paczke_klient(42, 833);
select wloz_paczke_klient(42, 834);
select wloz_paczke_klient(42, 835);
select wloz_paczke_klient(42, 836);
select wloz_paczke_klient(42, 837);
select wloz_paczke_klient(42, 838);
select wloz_paczke_klient(42, 839);
select wloz_paczke_klient(42, 840);
select wloz_paczke_klient(43, 841);
select wloz_paczke_klient(43, 842);
select wloz_paczke_klient(43, 843);
select wloz_paczke_klient(43, 844);
select wloz_paczke_klient(43, 845);
select wloz_paczke_klient(43, 846);
select wloz_paczke_klient(43, 847);
select wloz_paczke_klient(43, 848);
select wloz_paczke_klient(43, 849);
select wloz_paczke_klient(43, 850);
select wloz_paczke_klient(43, 851);
select wloz_paczke_klient(43, 852);
select wloz_paczke_klient(43, 853);
select wloz_paczke_klient(43, 854);
select wloz_paczke_klient(43, 855);
select wloz_paczke_klient(43, 856);
select wloz_paczke_klient(43, 857);
select wloz_paczke_klient(43, 858);
select wloz_paczke_klient(43, 859);
select wloz_paczke_klient(43, 860);
select wloz_paczke_klient(44, 861);
select wloz_paczke_klient(44, 862);
select wloz_paczke_klient(44, 863);
select wloz_paczke_klient(44, 864);
select wloz_paczke_klient(44, 865);
select wloz_paczke_klient(44, 866);
select wloz_paczke_klient(44, 867);
select wloz_paczke_klient(44, 868);
select wloz_paczke_klient(44, 869);
select wloz_paczke_klient(44, 870);
select wloz_paczke_klient(44, 871);
select wloz_paczke_klient(44, 872);
select wloz_paczke_klient(44, 873);
select wloz_paczke_klient(44, 874);
select wloz_paczke_klient(44, 875);
select wloz_paczke_klient(44, 876);
select wloz_paczke_klient(44, 877);
select wloz_paczke_klient(44, 878);
select wloz_paczke_klient(44, 879);
select wloz_paczke_klient(44, 880);
select wloz_paczke_klient(45, 881);
select wloz_paczke_klient(45, 882);
select wloz_paczke_klient(45, 883);
select wloz_paczke_klient(45, 884);
select wloz_paczke_klient(45, 885);
select wloz_paczke_klient(45, 886);
select wloz_paczke_klient(45, 887);
select wloz_paczke_klient(45, 888);
select wloz_paczke_klient(45, 889);
select wloz_paczke_klient(45, 890);
select wloz_paczke_klient(45, 891);
select wloz_paczke_klient(45, 892);
select wloz_paczke_klient(45, 893);
select wloz_paczke_klient(45, 894);
select wloz_paczke_klient(45, 895);
select wloz_paczke_klient(45, 896);
select wloz_paczke_klient(45, 897);
select wloz_paczke_klient(45, 898);
select wloz_paczke_klient(45, 899);
select wloz_paczke_klient(45, 900);
select wloz_paczke_klient(46, 901);
select wloz_paczke_klient(46, 902);
select wloz_paczke_klient(46, 903);
select wloz_paczke_klient(46, 904);
select wloz_paczke_klient(46, 905);
select wloz_paczke_klient(46, 906);
select wloz_paczke_klient(46, 907);
select wloz_paczke_klient(46, 908);
select wloz_paczke_klient(46, 909);
select wloz_paczke_klient(46, 910);
select wloz_paczke_klient(46, 911);
select wloz_paczke_klient(46, 912);
select wloz_paczke_klient(46, 913);
select wloz_paczke_klient(46, 914);
select wloz_paczke_klient(46, 915);
select wloz_paczke_klient(46, 916);
select wloz_paczke_klient(46, 917);
select wloz_paczke_klient(46, 918);
select wloz_paczke_klient(46, 919);
select wloz_paczke_klient(46, 920);
select wloz_paczke_klient(47, 921);
select wloz_paczke_klient(47, 922);
select wloz_paczke_klient(47, 923);
select wloz_paczke_klient(47, 924);
select wloz_paczke_klient(47, 925);
select wloz_paczke_klient(47, 926);
select wloz_paczke_klient(47, 927);
select wloz_paczke_klient(47, 928);
select wloz_paczke_klient(47, 929);
select wloz_paczke_klient(47, 930);
select wloz_paczke_klient(47, 931);
select wloz_paczke_klient(47, 932);
select wloz_paczke_klient(47, 933);
select wloz_paczke_klient(47, 934);
select wloz_paczke_klient(47, 935);
select wloz_paczke_klient(47, 936);
select wloz_paczke_klient(47, 937);
select wloz_paczke_klient(47, 938);
select wloz_paczke_klient(47, 939);
select wloz_paczke_klient(47, 940);
select wloz_paczke_klient(48, 941);
select wloz_paczke_klient(48, 942);
select wloz_paczke_klient(48, 943);
select wloz_paczke_klient(48, 944);
select wloz_paczke_klient(48, 945);
select wloz_paczke_klient(48, 946);
select wloz_paczke_klient(48, 947);
select wloz_paczke_klient(48, 948);
select wloz_paczke_klient(48, 949);
select wloz_paczke_klient(48, 950);
select wloz_paczke_klient(48, 951);
select wloz_paczke_klient(48, 952);
select wloz_paczke_klient(48, 953);
select wloz_paczke_klient(48, 954);
select wloz_paczke_klient(48, 955);
select wloz_paczke_klient(48, 956);
select wloz_paczke_klient(48, 957);
select wloz_paczke_klient(48, 958);
select wloz_paczke_klient(48, 959);
select wloz_paczke_klient(48, 960);
select wloz_paczke_klient(49, 961);
select wloz_paczke_klient(49, 962);
select wloz_paczke_klient(49, 963);
select wloz_paczke_klient(49, 964);
select wloz_paczke_klient(49, 965);
select wloz_paczke_klient(49, 966);
select wloz_paczke_klient(49, 967);
select wloz_paczke_klient(49, 968);
select wloz_paczke_klient(49, 969);
select wloz_paczke_klient(49, 970);
select wloz_paczke_klient(49, 971);
select wloz_paczke_klient(49, 972);
select wloz_paczke_klient(49, 973);
select wloz_paczke_klient(49, 974);
select wloz_paczke_klient(49, 975);
select wloz_paczke_klient(49, 976);
select wloz_paczke_klient(49, 977);
select wloz_paczke_klient(49, 978);
select wloz_paczke_klient(49, 979);
select wloz_paczke_klient(49, 980);
select wloz_paczke_klient(50, 981);
select wloz_paczke_klient(50, 982);
select wloz_paczke_klient(50, 983);
select wloz_paczke_klient(50, 984);
select wloz_paczke_klient(50, 985);
select wloz_paczke_klient(50, 986);
select wloz_paczke_klient(50, 987);
select wloz_paczke_klient(50, 988);
select wloz_paczke_klient(50, 989);
select wloz_paczke_klient(50, 990);
select wloz_paczke_klient(50, 991);
select wloz_paczke_klient(50, 992);
select wloz_paczke_klient(50, 993);
select wloz_paczke_klient(50, 994);
select wloz_paczke_klient(50, 995);
select wloz_paczke_klient(50, 996);
select wloz_paczke_klient(50, 997);
select wloz_paczke_klient(50, 998);
select wloz_paczke_klient(50, 999);
select wloz_paczke_klient(50, 1000);
select wloz_paczke_klient(51, 1001);
select wloz_paczke_klient(51, 1002);
select wloz_paczke_klient(51, 1003);
select wloz_paczke_klient(51, 1004);
select wloz_paczke_klient(51, 1005);
select wloz_paczke_klient(51, 1006);
select wloz_paczke_klient(51, 1007);
select wloz_paczke_klient(51, 1008);
select wloz_paczke_klient(51, 1009);
select wloz_paczke_klient(51, 1010);
select wloz_paczke_klient(51, 1011);
select wloz_paczke_klient(51, 1012);
select wloz_paczke_klient(51, 1013);
select wloz_paczke_klient(51, 1014);
select wloz_paczke_klient(51, 1015);
select wloz_paczke_klient(51, 1016);
select wloz_paczke_klient(51, 1017);
select wloz_paczke_klient(51, 1018);
select wloz_paczke_klient(51, 1019);
select wloz_paczke_klient(51, 1020);
select wloz_paczke_klient(52, 1021);
select wloz_paczke_klient(52, 1022);
select wloz_paczke_klient(52, 1023);
select wloz_paczke_klient(52, 1024);
select wloz_paczke_klient(52, 1025);
select wloz_paczke_klient(52, 1026);
select wloz_paczke_klient(52, 1027);
select wloz_paczke_klient(52, 1028);
select wloz_paczke_klient(52, 1029);
select wloz_paczke_klient(52, 1030);
select wloz_paczke_klient(52, 1031);
select wloz_paczke_klient(52, 1032);
select wloz_paczke_klient(52, 1033);
select wloz_paczke_klient(52, 1034);
select wloz_paczke_klient(52, 1035);
select wloz_paczke_klient(52, 1036);
select wloz_paczke_klient(52, 1037);
select wloz_paczke_klient(52, 1038);
select wloz_paczke_klient(52, 1039);
select wloz_paczke_klient(52, 1040);
select wloz_paczke_klient(53, 1041);
select wloz_paczke_klient(53, 1042);
select wloz_paczke_klient(53, 1043);
select wloz_paczke_klient(53, 1044);
select wloz_paczke_klient(53, 1045);
select wloz_paczke_klient(53, 1046);
select wloz_paczke_klient(53, 1047);
select wloz_paczke_klient(53, 1048);
select wloz_paczke_klient(53, 1049);
select wloz_paczke_klient(53, 1050);
select wloz_paczke_klient(53, 1051);
select wloz_paczke_klient(53, 1052);
select wloz_paczke_klient(53, 1053);
select wloz_paczke_klient(53, 1054);
select wloz_paczke_klient(53, 1055);
select wloz_paczke_klient(53, 1056);
select wloz_paczke_klient(53, 1057);
select wloz_paczke_klient(53, 1058);
select wloz_paczke_klient(53, 1059);
select wloz_paczke_klient(53, 1060);
select wloz_paczke_klient(54, 1061);
select wloz_paczke_klient(54, 1062);
select wloz_paczke_klient(54, 1063);
select wloz_paczke_klient(54, 1064);
select wloz_paczke_klient(54, 1065);
select wloz_paczke_klient(54, 1066);
select wloz_paczke_klient(54, 1067);
select wloz_paczke_klient(54, 1068);
select wloz_paczke_klient(54, 1069);
select wloz_paczke_klient(54, 1070);
select wloz_paczke_klient(54, 1071);
select wloz_paczke_klient(54, 1072);
select wloz_paczke_klient(54, 1073);
select wloz_paczke_klient(54, 1074);
select wloz_paczke_klient(54, 1075);
select wloz_paczke_klient(54, 1076);
select wloz_paczke_klient(54, 1077);
select wloz_paczke_klient(54, 1078);
select wloz_paczke_klient(54, 1079);
select wloz_paczke_klient(54, 1080);
select wloz_paczke_klient(55, 1081);
select wloz_paczke_klient(55, 1082);
select wloz_paczke_klient(55, 1083);
select wloz_paczke_klient(55, 1084);
select wloz_paczke_klient(55, 1085);
select wloz_paczke_klient(55, 1086);
select wloz_paczke_klient(55, 1087);
select wloz_paczke_klient(55, 1088);
select wloz_paczke_klient(55, 1089);
select wloz_paczke_klient(55, 1090);
select wloz_paczke_klient(55, 1091);
select wloz_paczke_klient(55, 1092);
select wloz_paczke_klient(55, 1093);
select wloz_paczke_klient(55, 1094);
select wloz_paczke_klient(55, 1095);
select wloz_paczke_klient(55, 1096);
select wloz_paczke_klient(55, 1097);
select wloz_paczke_klient(55, 1098);
select wloz_paczke_klient(55, 1099);
select wloz_paczke_klient(55, 1100);
select wloz_paczke_klient(56, 1101);
select wloz_paczke_klient(56, 1102);
select wloz_paczke_klient(56, 1103);
select wloz_paczke_klient(56, 1104);
select wloz_paczke_klient(56, 1105);
select wloz_paczke_klient(56, 1106);
select wloz_paczke_klient(56, 1107);
select wloz_paczke_klient(56, 1108);
select wloz_paczke_klient(56, 1109);
select wloz_paczke_klient(56, 1110);
select wloz_paczke_klient(56, 1111);
select wloz_paczke_klient(56, 1112);
select wloz_paczke_klient(56, 1113);
select wloz_paczke_klient(56, 1114);
select wloz_paczke_klient(56, 1115);
select wloz_paczke_klient(56, 1116);
select wloz_paczke_klient(56, 1117);
select wloz_paczke_klient(56, 1118);
select wloz_paczke_klient(56, 1119);
select wloz_paczke_klient(56, 1120);
select wloz_paczke_klient(57, 1121);
select wloz_paczke_klient(57, 1122);
select wloz_paczke_klient(57, 1123);
select wloz_paczke_klient(57, 1124);
select wloz_paczke_klient(57, 1125);
select wloz_paczke_klient(57, 1126);
select wloz_paczke_klient(57, 1127);
select wloz_paczke_klient(57, 1128);
select wloz_paczke_klient(57, 1129);
select wloz_paczke_klient(57, 1130);
select wloz_paczke_klient(57, 1131);
select wloz_paczke_klient(57, 1132);
select wloz_paczke_klient(57, 1133);
select wloz_paczke_klient(57, 1134);
select wloz_paczke_klient(57, 1135);
select wloz_paczke_klient(57, 1136);
select wloz_paczke_klient(57, 1137);
select wloz_paczke_klient(57, 1138);
select wloz_paczke_klient(57, 1139);
select wloz_paczke_klient(57, 1140);
select wloz_paczke_klient(58, 1141);
select wloz_paczke_klient(58, 1142);
select wloz_paczke_klient(58, 1143);
select wloz_paczke_klient(58, 1144);
select wloz_paczke_klient(58, 1145);
select wloz_paczke_klient(58, 1146);
select wloz_paczke_klient(58, 1147);
select wloz_paczke_klient(58, 1148);
select wloz_paczke_klient(58, 1149);
select wloz_paczke_klient(58, 1150);
select wloz_paczke_klient(58, 1151);
select wloz_paczke_klient(58, 1152);
select wloz_paczke_klient(58, 1153);
select wloz_paczke_klient(58, 1154);
select wloz_paczke_klient(58, 1155);
select wloz_paczke_klient(58, 1156);
select wloz_paczke_klient(58, 1157);
select wloz_paczke_klient(58, 1158);
select wloz_paczke_klient(58, 1159);
select wloz_paczke_klient(58, 1160);
select wloz_paczke_klient(59, 1161);
select wloz_paczke_klient(59, 1162);
select wloz_paczke_klient(59, 1163);
select wloz_paczke_klient(59, 1164);
select wloz_paczke_klient(59, 1165);
select wloz_paczke_klient(59, 1166);
select wloz_paczke_klient(59, 1167);
select wloz_paczke_klient(59, 1168);
select wloz_paczke_klient(59, 1169);
select wloz_paczke_klient(59, 1170);
select wloz_paczke_klient(59, 1171);
select wloz_paczke_klient(59, 1172);
select wloz_paczke_klient(59, 1173);
select wloz_paczke_klient(59, 1174);
select wloz_paczke_klient(59, 1175);
select wloz_paczke_klient(59, 1176);
select wloz_paczke_klient(59, 1177);
select wloz_paczke_klient(59, 1178);
select wloz_paczke_klient(59, 1179);
select wloz_paczke_klient(59, 1180);
select wloz_paczke_klient(60, 1181);
select wloz_paczke_klient(60, 1182);
select wloz_paczke_klient(60, 1183);
select wloz_paczke_klient(60, 1184);
select wloz_paczke_klient(60, 1185);
select wloz_paczke_klient(60, 1186);
select wloz_paczke_klient(60, 1187);
select wloz_paczke_klient(60, 1188);
select wloz_paczke_klient(60, 1189);
select wloz_paczke_klient(60, 1190);
select wloz_paczke_klient(60, 1191);
select wloz_paczke_klient(60, 1192);
select wloz_paczke_klient(60, 1193);
select wloz_paczke_klient(60, 1194);
select wloz_paczke_klient(60, 1195);
select wloz_paczke_klient(60, 1196);
select wloz_paczke_klient(60, 1197);
select wloz_paczke_klient(60, 1198);
select wloz_paczke_klient(60, 1199);
select wloz_paczke_klient(60, 1200);
select wloz_paczke_klient(61, 1201);
select wloz_paczke_klient(61, 1202);
select wloz_paczke_klient(61, 1203);
select wloz_paczke_klient(61, 1204);
select wloz_paczke_klient(61, 1205);
select wloz_paczke_klient(61, 1206);
select wloz_paczke_klient(61, 1207);
select wloz_paczke_klient(61, 1208);
select wloz_paczke_klient(61, 1209);
select wloz_paczke_klient(61, 1210);
select wloz_paczke_klient(61, 1211);
select wloz_paczke_klient(61, 1212);
select wloz_paczke_klient(61, 1213);
select wloz_paczke_klient(61, 1214);
select wloz_paczke_klient(61, 1215);
select wloz_paczke_klient(61, 1216);
select wloz_paczke_klient(61, 1217);
select wloz_paczke_klient(61, 1218);
select wloz_paczke_klient(61, 1219);
select wloz_paczke_klient(61, 1220);
select wloz_paczke_klient(62, 1221);
select wloz_paczke_klient(62, 1222);
select wloz_paczke_klient(62, 1223);
select wloz_paczke_klient(62, 1224);
select wloz_paczke_klient(62, 1225);
select wloz_paczke_klient(62, 1226);
select wloz_paczke_klient(62, 1227);
select wloz_paczke_klient(62, 1228);
select wloz_paczke_klient(62, 1229);
select wloz_paczke_klient(62, 1230);
select wloz_paczke_klient(62, 1231);
select wloz_paczke_klient(62, 1232);
select wloz_paczke_klient(62, 1233);
select wloz_paczke_klient(62, 1234);
select wloz_paczke_klient(62, 1235);
select wloz_paczke_klient(62, 1236);
select wloz_paczke_klient(62, 1237);
select wloz_paczke_klient(62, 1238);
select wloz_paczke_klient(62, 1239);
select wloz_paczke_klient(62, 1240);
select wloz_paczke_klient(63, 1241);
select wloz_paczke_klient(63, 1242);
select wloz_paczke_klient(63, 1243);
select wloz_paczke_klient(63, 1244);
select wloz_paczke_klient(63, 1245);
select wloz_paczke_klient(63, 1246);
select wloz_paczke_klient(63, 1247);
select wloz_paczke_klient(63, 1248);
select wloz_paczke_klient(63, 1249);
select wloz_paczke_klient(63, 1250);
select wloz_paczke_klient(63, 1251);
select wloz_paczke_klient(63, 1252);
select wloz_paczke_klient(63, 1253);
select wloz_paczke_klient(63, 1254);
select wloz_paczke_klient(63, 1255);
select wloz_paczke_klient(63, 1256);
select wloz_paczke_klient(63, 1257);
select wloz_paczke_klient(63, 1258);
select wloz_paczke_klient(63, 1259);
select wloz_paczke_klient(63, 1260);
select wloz_paczke_klient(64, 1261);
select wloz_paczke_klient(64, 1262);
select wloz_paczke_klient(64, 1263);
select wloz_paczke_klient(64, 1264);
select wloz_paczke_klient(64, 1265);
select wloz_paczke_klient(64, 1266);
select wloz_paczke_klient(64, 1267);
select wloz_paczke_klient(64, 1268);
select wloz_paczke_klient(64, 1269);
select wloz_paczke_klient(64, 1270);
select wloz_paczke_klient(64, 1271);
select wloz_paczke_klient(64, 1272);
select wloz_paczke_klient(64, 1273);
select wloz_paczke_klient(64, 1274);
select wloz_paczke_klient(64, 1275);
select wloz_paczke_klient(64, 1276);
select wloz_paczke_klient(64, 1277);
select wloz_paczke_klient(64, 1278);
select wloz_paczke_klient(64, 1279);
select wloz_paczke_klient(64, 1280);
select wloz_paczke_klient(65, 1281);
select wloz_paczke_klient(65, 1282);
select wloz_paczke_klient(65, 1283);
select wloz_paczke_klient(65, 1284);
select wloz_paczke_klient(65, 1285);
select wloz_paczke_klient(65, 1286);
select wloz_paczke_klient(65, 1287);
select wloz_paczke_klient(65, 1288);
select wloz_paczke_klient(65, 1289);
select wloz_paczke_klient(65, 1290);
select wloz_paczke_klient(65, 1291);
select wloz_paczke_klient(65, 1292);
select wloz_paczke_klient(65, 1293);
select wloz_paczke_klient(65, 1294);
select wloz_paczke_klient(65, 1295);
select wloz_paczke_klient(65, 1296);
select wloz_paczke_klient(65, 1297);
select wloz_paczke_klient(65, 1298);
select wloz_paczke_klient(65, 1299);
select wloz_paczke_klient(65, 1300);
select wloz_paczke_klient(66, 1301);
select wloz_paczke_klient(66, 1302);
select wloz_paczke_klient(66, 1303);
select wloz_paczke_klient(66, 1304);
select wloz_paczke_klient(66, 1305);
select wloz_paczke_klient(66, 1306);
select wloz_paczke_klient(66, 1307);
select wloz_paczke_klient(66, 1308);
select wloz_paczke_klient(66, 1309);
select wloz_paczke_klient(66, 1310);
select wloz_paczke_klient(66, 1311);
select wloz_paczke_klient(66, 1312);
select wloz_paczke_klient(66, 1313);
select wloz_paczke_klient(66, 1314);
select wloz_paczke_klient(66, 1315);
select wloz_paczke_klient(66, 1316);
select wloz_paczke_klient(66, 1317);
select wloz_paczke_klient(66, 1318);
select wloz_paczke_klient(66, 1319);
select wloz_paczke_klient(66, 1320);
select wloz_paczke_klient(67, 1321);
select wloz_paczke_klient(67, 1322);
select wloz_paczke_klient(67, 1323);
select wloz_paczke_klient(67, 1324);
select wloz_paczke_klient(67, 1325);
select wloz_paczke_klient(67, 1326);
select wloz_paczke_klient(67, 1327);
select wloz_paczke_klient(67, 1328);
select wloz_paczke_klient(67, 1329);
select wloz_paczke_klient(67, 1330);
select wloz_paczke_klient(67, 1331);
select wloz_paczke_klient(67, 1332);
select wloz_paczke_klient(67, 1333);
select wloz_paczke_klient(67, 1334);
select wloz_paczke_klient(67, 1335);
select wloz_paczke_klient(67, 1336);
select wloz_paczke_klient(67, 1337);
select wloz_paczke_klient(67, 1338);
select wloz_paczke_klient(67, 1339);
select wloz_paczke_klient(67, 1340);
select wloz_paczke_klient(68, 1341);
select wloz_paczke_klient(68, 1342);
select wloz_paczke_klient(68, 1343);
select wloz_paczke_klient(68, 1344);
select wloz_paczke_klient(68, 1345);
select wloz_paczke_klient(68, 1346);
select wloz_paczke_klient(68, 1347);
select wloz_paczke_klient(68, 1348);
select wloz_paczke_klient(68, 1349);
select wloz_paczke_klient(68, 1350);
select wloz_paczke_klient(68, 1351);
select wloz_paczke_klient(68, 1352);
select wloz_paczke_klient(68, 1353);
select wloz_paczke_klient(68, 1354);
select wloz_paczke_klient(68, 1355);
select wloz_paczke_klient(68, 1356);
select wloz_paczke_klient(68, 1357);
select wloz_paczke_klient(68, 1358);
select wloz_paczke_klient(68, 1359);
select wloz_paczke_klient(68, 1360);
select wloz_paczke_klient(69, 1361);
select wloz_paczke_klient(69, 1362);
select wloz_paczke_klient(69, 1363);
select wloz_paczke_klient(69, 1364);
select wloz_paczke_klient(69, 1365);
select wloz_paczke_klient(69, 1366);
select wloz_paczke_klient(69, 1367);
select wloz_paczke_klient(69, 1368);
select wloz_paczke_klient(69, 1369);
select wloz_paczke_klient(69, 1370);
select wloz_paczke_klient(69, 1371);
select wloz_paczke_klient(69, 1372);
select wloz_paczke_klient(69, 1373);
select wloz_paczke_klient(69, 1374);
select wloz_paczke_klient(69, 1375);
select wloz_paczke_klient(69, 1376);
select wloz_paczke_klient(69, 1377);
select wloz_paczke_klient(69, 1378);
select wloz_paczke_klient(69, 1379);
select wloz_paczke_klient(69, 1380);
select wloz_paczke_klient(70, 1381);
select wloz_paczke_klient(70, 1382);
select wloz_paczke_klient(70, 1383);
select wloz_paczke_klient(70, 1384);
select wloz_paczke_klient(70, 1385);
select wloz_paczke_klient(70, 1386);
select wloz_paczke_klient(70, 1387);
select wloz_paczke_klient(70, 1388);
select wloz_paczke_klient(70, 1389);
select wloz_paczke_klient(70, 1390);
select wloz_paczke_klient(70, 1391);
select wloz_paczke_klient(70, 1392);
select wloz_paczke_klient(70, 1393);
select wloz_paczke_klient(70, 1394);
select wloz_paczke_klient(70, 1395);
select wloz_paczke_klient(70, 1396);
select wloz_paczke_klient(70, 1397);
select wloz_paczke_klient(70, 1398);
select wloz_paczke_klient(70, 1399);
select wloz_paczke_klient(70, 1400);
select wloz_paczke_klient(71, 1401);
select wloz_paczke_klient(71, 1402);
select wloz_paczke_klient(71, 1403);
select wloz_paczke_klient(71, 1404);
select wloz_paczke_klient(71, 1405);
select wloz_paczke_klient(71, 1406);
select wloz_paczke_klient(71, 1407);
select wloz_paczke_klient(71, 1408);
select wloz_paczke_klient(71, 1409);
select wloz_paczke_klient(71, 1410);
select wloz_paczke_klient(71, 1411);
select wloz_paczke_klient(71, 1412);
select wloz_paczke_klient(71, 1413);
select wloz_paczke_klient(71, 1414);
select wloz_paczke_klient(71, 1415);
select wloz_paczke_klient(71, 1416);
select wloz_paczke_klient(71, 1417);
select wloz_paczke_klient(71, 1418);
select wloz_paczke_klient(71, 1419);
select wloz_paczke_klient(71, 1420);
select wloz_paczke_klient(72, 1421);
select wloz_paczke_klient(72, 1422);
select wloz_paczke_klient(72, 1423);
select wloz_paczke_klient(72, 1424);
select wloz_paczke_klient(72, 1425);
select wloz_paczke_klient(72, 1426);
select wloz_paczke_klient(72, 1427);
select wloz_paczke_klient(72, 1428);
select wloz_paczke_klient(72, 1429);
select wloz_paczke_klient(72, 1430);
select wloz_paczke_klient(72, 1431);
select wloz_paczke_klient(72, 1432);
select wloz_paczke_klient(72, 1433);
select wloz_paczke_klient(72, 1434);
select wloz_paczke_klient(72, 1435);
select wloz_paczke_klient(72, 1436);
select wloz_paczke_klient(72, 1437);
select wloz_paczke_klient(72, 1438);
select wloz_paczke_klient(72, 1439);
select wloz_paczke_klient(72, 1440);
select wloz_paczke_klient(73, 1441);
select wloz_paczke_klient(73, 1442);
select wloz_paczke_klient(73, 1443);
select wloz_paczke_klient(73, 1444);
select wloz_paczke_klient(73, 1445);
select wloz_paczke_klient(73, 1446);
select wloz_paczke_klient(73, 1447);
select wloz_paczke_klient(73, 1448);
select wloz_paczke_klient(73, 1449);
select wloz_paczke_klient(73, 1450);
select wloz_paczke_klient(73, 1451);
select wloz_paczke_klient(73, 1452);
select wloz_paczke_klient(73, 1453);
select wloz_paczke_klient(73, 1454);
select wloz_paczke_klient(73, 1455);
select wloz_paczke_klient(73, 1456);
select wloz_paczke_klient(73, 1457);
select wloz_paczke_klient(73, 1458);
select wloz_paczke_klient(73, 1459);
select wloz_paczke_klient(73, 1460);
select wloz_paczke_klient(74, 1461);
select wloz_paczke_klient(74, 1462);
select wloz_paczke_klient(74, 1463);
select wloz_paczke_klient(74, 1464);
select wloz_paczke_klient(74, 1465);
select wloz_paczke_klient(74, 1466);
select wloz_paczke_klient(74, 1467);
select wloz_paczke_klient(74, 1468);
select wloz_paczke_klient(74, 1469);
select wloz_paczke_klient(74, 1470);
select wloz_paczke_klient(74, 1471);
select wloz_paczke_klient(74, 1472);
select wloz_paczke_klient(74, 1473);
select wloz_paczke_klient(74, 1474);
select wloz_paczke_klient(74, 1475);
select wloz_paczke_klient(74, 1476);
select wloz_paczke_klient(74, 1477);
select wloz_paczke_klient(74, 1478);
select wloz_paczke_klient(74, 1479);
select wloz_paczke_klient(74, 1480);
select wloz_paczke_klient(75, 1481);
select wloz_paczke_klient(75, 1482);
select wloz_paczke_klient(75, 1483);
select wloz_paczke_klient(75, 1484);
select wloz_paczke_klient(75, 1485);
select wloz_paczke_klient(75, 1486);
select wloz_paczke_klient(75, 1487);
select wloz_paczke_klient(75, 1488);
select wloz_paczke_klient(75, 1489);
select wloz_paczke_klient(75, 1490);
select wloz_paczke_klient(75, 1491);
select wloz_paczke_klient(75, 1492);
select wloz_paczke_klient(75, 1493);
select wloz_paczke_klient(75, 1494);
select wloz_paczke_klient(75, 1495);
select wloz_paczke_klient(75, 1496);
select wloz_paczke_klient(75, 1497);
select wloz_paczke_klient(75, 1498);
select wloz_paczke_klient(75, 1499);
select wloz_paczke_klient(75, 1500);
select wloz_paczke_klient(76, 1501);
select wloz_paczke_klient(76, 1502);
select wloz_paczke_klient(76, 1503);
select wloz_paczke_klient(76, 1504);
select wloz_paczke_klient(76, 1505);
select wloz_paczke_klient(76, 1506);
select wloz_paczke_klient(76, 1507);
select wloz_paczke_klient(76, 1508);
select wloz_paczke_klient(76, 1509);
select wloz_paczke_klient(76, 1510);
select wloz_paczke_klient(76, 1511);
select wloz_paczke_klient(76, 1512);
select wloz_paczke_klient(76, 1513);
select wloz_paczke_klient(76, 1514);
select wloz_paczke_klient(76, 1515);
select wloz_paczke_klient(76, 1516);
select wloz_paczke_klient(76, 1517);
select wloz_paczke_klient(76, 1518);
select wloz_paczke_klient(76, 1519);
select wloz_paczke_klient(76, 1520);
select wloz_paczke_klient(77, 1521);
select wloz_paczke_klient(77, 1522);
select wloz_paczke_klient(77, 1523);
select wloz_paczke_klient(77, 1524);
select wloz_paczke_klient(77, 1525);
select wloz_paczke_klient(77, 1526);
select wloz_paczke_klient(77, 1527);
select wloz_paczke_klient(77, 1528);
select wloz_paczke_klient(77, 1529);
select wloz_paczke_klient(77, 1530);
select wloz_paczke_klient(77, 1531);
select wloz_paczke_klient(77, 1532);
select wloz_paczke_klient(77, 1533);
select wloz_paczke_klient(77, 1534);
select wloz_paczke_klient(77, 1535);
select wloz_paczke_klient(77, 1536);
select wloz_paczke_klient(77, 1537);
select wloz_paczke_klient(77, 1538);
select wloz_paczke_klient(77, 1539);
select wloz_paczke_klient(77, 1540);
select wloz_paczke_klient(78, 1541);
select wloz_paczke_klient(78, 1542);
select wloz_paczke_klient(78, 1543);
select wloz_paczke_klient(78, 1544);
select wloz_paczke_klient(78, 1545);
select wloz_paczke_klient(78, 1546);
select wloz_paczke_klient(78, 1547);
select wloz_paczke_klient(78, 1548);
select wloz_paczke_klient(78, 1549);
select wloz_paczke_klient(78, 1550);
select wloz_paczke_klient(78, 1551);
select wloz_paczke_klient(78, 1552);
select wloz_paczke_klient(78, 1553);
select wloz_paczke_klient(78, 1554);
select wloz_paczke_klient(78, 1555);
select wloz_paczke_klient(78, 1556);
select wloz_paczke_klient(78, 1557);
select wloz_paczke_klient(78, 1558);
select wloz_paczke_klient(78, 1559);
select wloz_paczke_klient(78, 1560);
select wloz_paczke_klient(79, 1561);
select wloz_paczke_klient(79, 1562);
select wloz_paczke_klient(79, 1563);
select wloz_paczke_klient(79, 1564);
select wloz_paczke_klient(79, 1565);
select wloz_paczke_klient(79, 1566);
select wloz_paczke_klient(79, 1567);
select wloz_paczke_klient(79, 1568);
select wloz_paczke_klient(79, 1569);
select wloz_paczke_klient(79, 1570);
select wloz_paczke_klient(79, 1571);
select wloz_paczke_klient(79, 1572);
select wloz_paczke_klient(79, 1573);
select wloz_paczke_klient(79, 1574);
select wloz_paczke_klient(79, 1575);
select wloz_paczke_klient(79, 1576);
select wloz_paczke_klient(79, 1577);
select wloz_paczke_klient(79, 1578);
select wloz_paczke_klient(79, 1579);
select wloz_paczke_klient(79, 1580);
select wloz_paczke_klient(80, 1581);
select wloz_paczke_klient(80, 1582);
select wloz_paczke_klient(80, 1583);
select wloz_paczke_klient(80, 1584);
select wloz_paczke_klient(80, 1585);
select wloz_paczke_klient(80, 1586);
select wloz_paczke_klient(80, 1587);
select wloz_paczke_klient(80, 1588);
select wloz_paczke_klient(80, 1589);
select wloz_paczke_klient(80, 1590);
select wloz_paczke_klient(80, 1591);
select wloz_paczke_klient(80, 1592);
select wloz_paczke_klient(80, 1593);
select wloz_paczke_klient(80, 1594);
select wloz_paczke_klient(80, 1595);
select wloz_paczke_klient(80, 1596);
select wloz_paczke_klient(80, 1597);
select wloz_paczke_klient(80, 1598);
select wloz_paczke_klient(80, 1599);
select wloz_paczke_klient(80, 1600);
select wloz_paczke_klient(81, 1601);
select wloz_paczke_klient(81, 1602);
select wloz_paczke_klient(81, 1603);
select wloz_paczke_klient(81, 1604);
select wloz_paczke_klient(81, 1605);
select wloz_paczke_klient(81, 1606);
select wloz_paczke_klient(81, 1607);
select wloz_paczke_klient(81, 1608);
select wloz_paczke_klient(81, 1609);
select wloz_paczke_klient(81, 1610);
select wloz_paczke_klient(81, 1611);
select wloz_paczke_klient(81, 1612);
select wloz_paczke_klient(81, 1613);
select wloz_paczke_klient(81, 1614);
select wloz_paczke_klient(81, 1615);
select wloz_paczke_klient(81, 1616);
select wloz_paczke_klient(81, 1617);
select wloz_paczke_klient(81, 1618);
select wloz_paczke_klient(81, 1619);
select wloz_paczke_klient(81, 1620);
select wloz_paczke_klient(82, 1621);
select wloz_paczke_klient(82, 1622);
select wloz_paczke_klient(82, 1623);
select wloz_paczke_klient(82, 1624);
select wloz_paczke_klient(82, 1625);
select wloz_paczke_klient(82, 1626);
select wloz_paczke_klient(82, 1627);
select wloz_paczke_klient(82, 1628);
select wloz_paczke_klient(82, 1629);
select wloz_paczke_klient(82, 1630);
select wloz_paczke_klient(82, 1631);
select wloz_paczke_klient(82, 1632);
select wloz_paczke_klient(82, 1633);
select wloz_paczke_klient(82, 1634);
select wloz_paczke_klient(82, 1635);
select wloz_paczke_klient(82, 1636);
select wloz_paczke_klient(82, 1637);
select wloz_paczke_klient(82, 1638);
select wloz_paczke_klient(82, 1639);
select wloz_paczke_klient(82, 1640);
select wloz_paczke_klient(83, 1641);
select wloz_paczke_klient(83, 1642);
select wloz_paczke_klient(83, 1643);
select wloz_paczke_klient(83, 1644);
select wloz_paczke_klient(83, 1645);
select wloz_paczke_klient(83, 1646);
select wloz_paczke_klient(83, 1647);
select wloz_paczke_klient(83, 1648);
select wloz_paczke_klient(83, 1649);
select wloz_paczke_klient(83, 1650);
select wloz_paczke_klient(83, 1651);
select wloz_paczke_klient(83, 1652);
select wloz_paczke_klient(83, 1653);
select wloz_paczke_klient(83, 1654);
select wloz_paczke_klient(83, 1655);
select wloz_paczke_klient(83, 1656);
select wloz_paczke_klient(83, 1657);
select wloz_paczke_klient(83, 1658);
select wloz_paczke_klient(83, 1659);
select wloz_paczke_klient(83, 1660);
select wloz_paczke_klient(84, 1661);
select wloz_paczke_klient(84, 1662);
select wloz_paczke_klient(84, 1663);
select wloz_paczke_klient(84, 1664);
select wloz_paczke_klient(84, 1665);
select wloz_paczke_klient(84, 1666);
select wloz_paczke_klient(84, 1667);
select wloz_paczke_klient(84, 1668);
select wloz_paczke_klient(84, 1669);
select wloz_paczke_klient(84, 1670);
select wloz_paczke_klient(84, 1671);
select wloz_paczke_klient(84, 1672);
select wloz_paczke_klient(84, 1673);
select wloz_paczke_klient(84, 1674);
select wloz_paczke_klient(84, 1675);
select wloz_paczke_klient(84, 1676);
select wloz_paczke_klient(84, 1677);
select wloz_paczke_klient(84, 1678);
select wloz_paczke_klient(84, 1679);
select wloz_paczke_klient(84, 1680);
select wloz_paczke_klient(85, 1681);
select wloz_paczke_klient(85, 1682);
select wloz_paczke_klient(85, 1683);
select wloz_paczke_klient(85, 1684);
select wloz_paczke_klient(85, 1685);
select wloz_paczke_klient(85, 1686);
select wloz_paczke_klient(85, 1687);
select wloz_paczke_klient(85, 1688);
select wloz_paczke_klient(85, 1689);
select wloz_paczke_klient(85, 1690);
select wloz_paczke_klient(85, 1691);
select wloz_paczke_klient(85, 1692);
select wloz_paczke_klient(85, 1693);
select wloz_paczke_klient(85, 1694);
select wloz_paczke_klient(85, 1695);
select wloz_paczke_klient(85, 1696);
select wloz_paczke_klient(85, 1697);
select wloz_paczke_klient(85, 1698);
select wloz_paczke_klient(85, 1699);
select wloz_paczke_klient(85, 1700);
select wloz_paczke_klient(86, 1701);
select wloz_paczke_klient(86, 1702);
select wloz_paczke_klient(86, 1703);
select wloz_paczke_klient(86, 1704);
select wloz_paczke_klient(86, 1705);
select wloz_paczke_klient(86, 1706);
select wloz_paczke_klient(86, 1707);
select wloz_paczke_klient(86, 1708);
select wloz_paczke_klient(86, 1709);
select wloz_paczke_klient(86, 1710);
select wloz_paczke_klient(86, 1711);
select wloz_paczke_klient(86, 1712);
select wloz_paczke_klient(86, 1713);
select wloz_paczke_klient(86, 1714);
select wloz_paczke_klient(86, 1715);
select wloz_paczke_klient(86, 1716);
select wloz_paczke_klient(86, 1717);
select wloz_paczke_klient(86, 1718);
select wloz_paczke_klient(86, 1719);
select wloz_paczke_klient(86, 1720);
select wloz_paczke_klient(87, 1721);
select wloz_paczke_klient(87, 1722);
select wloz_paczke_klient(87, 1723);
select wloz_paczke_klient(87, 1724);
select wloz_paczke_klient(87, 1725);
select wloz_paczke_klient(87, 1726);
select wloz_paczke_klient(87, 1727);
select wloz_paczke_klient(87, 1728);
select wloz_paczke_klient(87, 1729);
select wloz_paczke_klient(87, 1730);
select wloz_paczke_klient(87, 1731);
select wloz_paczke_klient(87, 1732);
select wloz_paczke_klient(87, 1733);
select wloz_paczke_klient(87, 1734);
select wloz_paczke_klient(87, 1735);
select wloz_paczke_klient(87, 1736);
select wloz_paczke_klient(87, 1737);
select wloz_paczke_klient(87, 1738);
select wloz_paczke_klient(87, 1739);
select wloz_paczke_klient(87, 1740);
select wloz_paczke_klient(88, 1741);
select wloz_paczke_klient(88, 1742);
select wloz_paczke_klient(88, 1743);
select wloz_paczke_klient(88, 1744);
select wloz_paczke_klient(88, 1745);
select wloz_paczke_klient(88, 1746);
select wloz_paczke_klient(88, 1747);
select wloz_paczke_klient(88, 1748);
select wloz_paczke_klient(88, 1749);
select wloz_paczke_klient(88, 1750);
select wloz_paczke_klient(88, 1751);
select wloz_paczke_klient(88, 1752);
select wloz_paczke_klient(88, 1753);
select wloz_paczke_klient(88, 1754);
select wloz_paczke_klient(88, 1755);
select wloz_paczke_klient(88, 1756);
select wloz_paczke_klient(88, 1757);
select wloz_paczke_klient(88, 1758);
select wloz_paczke_klient(88, 1759);
select wloz_paczke_klient(88, 1760);
select wloz_paczke_klient(89, 1761);
select wloz_paczke_klient(89, 1762);
select wloz_paczke_klient(89, 1763);
select wloz_paczke_klient(89, 1764);
select wloz_paczke_klient(89, 1765);
select wloz_paczke_klient(89, 1766);
select wloz_paczke_klient(89, 1767);
select wloz_paczke_klient(89, 1768);
select wloz_paczke_klient(89, 1769);
select wloz_paczke_klient(89, 1770);
select wloz_paczke_klient(89, 1771);
select wloz_paczke_klient(89, 1772);
select wloz_paczke_klient(89, 1773);
select wloz_paczke_klient(89, 1774);
select wloz_paczke_klient(89, 1775);
select wloz_paczke_klient(89, 1776);
select wloz_paczke_klient(89, 1777);
select wloz_paczke_klient(89, 1778);
select wloz_paczke_klient(89, 1779);
select wloz_paczke_klient(89, 1780);
select wloz_paczke_klient(90, 1781);
select wloz_paczke_klient(90, 1782);
select wloz_paczke_klient(90, 1783);
select wloz_paczke_klient(90, 1784);
select wloz_paczke_klient(90, 1785);
select wloz_paczke_klient(90, 1786);
select wloz_paczke_klient(90, 1787);
select wloz_paczke_klient(90, 1788);
select wloz_paczke_klient(90, 1789);
select wloz_paczke_klient(90, 1790);
select wloz_paczke_klient(90, 1791);
select wloz_paczke_klient(90, 1792);
select wloz_paczke_klient(90, 1793);
select wloz_paczke_klient(90, 1794);
select wloz_paczke_klient(90, 1795);
select wloz_paczke_klient(90, 1796);
select wloz_paczke_klient(90, 1797);
select wloz_paczke_klient(90, 1798);
select wloz_paczke_klient(90, 1799);
select wloz_paczke_klient(90, 1800);
select wloz_paczke_klient(91, 1801);
select wloz_paczke_klient(91, 1802);
select wloz_paczke_klient(91, 1803);
select wloz_paczke_klient(91, 1804);
select wloz_paczke_klient(91, 1805);
select wloz_paczke_klient(91, 1806);
select wloz_paczke_klient(91, 1807);
select wloz_paczke_klient(91, 1808);
select wloz_paczke_klient(91, 1809);
select wloz_paczke_klient(91, 1810);
select wloz_paczke_klient(91, 1811);
select wloz_paczke_klient(91, 1812);
select wloz_paczke_klient(91, 1813);
select wloz_paczke_klient(91, 1814);
select wloz_paczke_klient(91, 1815);
select wloz_paczke_klient(91, 1816);
select wloz_paczke_klient(91, 1817);
select wloz_paczke_klient(91, 1818);
select wloz_paczke_klient(91, 1819);
select wloz_paczke_klient(91, 1820);
select wloz_paczke_klient(92, 1821);
select wloz_paczke_klient(92, 1822);
select wloz_paczke_klient(92, 1823);
select wloz_paczke_klient(92, 1824);
select wloz_paczke_klient(92, 1825);
select wloz_paczke_klient(92, 1826);
select wloz_paczke_klient(92, 1827);
select wloz_paczke_klient(92, 1828);
select wloz_paczke_klient(92, 1829);
select wloz_paczke_klient(92, 1830);
select wloz_paczke_klient(92, 1831);
select wloz_paczke_klient(92, 1832);
select wloz_paczke_klient(92, 1833);
select wloz_paczke_klient(92, 1834);
select wloz_paczke_klient(92, 1835);
select wloz_paczke_klient(92, 1836);
select wloz_paczke_klient(92, 1837);
select wloz_paczke_klient(92, 1838);
select wloz_paczke_klient(92, 1839);
select wloz_paczke_klient(92, 1840);
select wloz_paczke_klient(93, 1841);
select wloz_paczke_klient(93, 1842);
select wloz_paczke_klient(93, 1843);
select wloz_paczke_klient(93, 1844);
select wloz_paczke_klient(93, 1845);
select wloz_paczke_klient(93, 1846);
select wloz_paczke_klient(93, 1847);
select wloz_paczke_klient(93, 1848);
select wloz_paczke_klient(93, 1849);
select wloz_paczke_klient(93, 1850);
select wloz_paczke_klient(93, 1851);
select wloz_paczke_klient(93, 1852);
select wloz_paczke_klient(93, 1853);
select wloz_paczke_klient(93, 1854);
select wloz_paczke_klient(93, 1855);
select wloz_paczke_klient(93, 1856);
select wloz_paczke_klient(93, 1857);
select wloz_paczke_klient(93, 1858);
select wloz_paczke_klient(93, 1859);
select wloz_paczke_klient(93, 1860);
select wloz_paczke_klient(94, 1861);
select wloz_paczke_klient(94, 1862);
select wloz_paczke_klient(94, 1863);
select wloz_paczke_klient(94, 1864);
select wloz_paczke_klient(94, 1865);
select wloz_paczke_klient(94, 1866);
select wloz_paczke_klient(94, 1867);
select wloz_paczke_klient(94, 1868);
select wloz_paczke_klient(94, 1869);
select wloz_paczke_klient(94, 1870);
select wloz_paczke_klient(94, 1871);
select wloz_paczke_klient(94, 1872);
select wloz_paczke_klient(94, 1873);
select wloz_paczke_klient(94, 1874);
select wloz_paczke_klient(94, 1875);
select wloz_paczke_klient(94, 1876);
select wloz_paczke_klient(94, 1877);
select wloz_paczke_klient(94, 1878);
select wloz_paczke_klient(94, 1879);
select wloz_paczke_klient(94, 1880);
select wloz_paczke_klient(95, 1881);
select wloz_paczke_klient(95, 1882);
select wloz_paczke_klient(95, 1883);
select wloz_paczke_klient(95, 1884);
select wloz_paczke_klient(95, 1885);
select wloz_paczke_klient(95, 1886);
select wloz_paczke_klient(95, 1887);
select wloz_paczke_klient(95, 1888);
select wloz_paczke_klient(95, 1889);
select wloz_paczke_klient(95, 1890);
select wloz_paczke_klient(95, 1891);
select wloz_paczke_klient(95, 1892);
select wloz_paczke_klient(95, 1893);
select wloz_paczke_klient(95, 1894);
select wloz_paczke_klient(95, 1895);
select wloz_paczke_klient(95, 1896);
select wloz_paczke_klient(95, 1897);
select wloz_paczke_klient(95, 1898);
select wloz_paczke_klient(95, 1899);
select wloz_paczke_klient(95, 1900);
select wloz_paczke_klient(96, 1901);
select wloz_paczke_klient(96, 1902);
select wloz_paczke_klient(96, 1903);
select wloz_paczke_klient(96, 1904);
select wloz_paczke_klient(96, 1905);
select wloz_paczke_klient(96, 1906);
select wloz_paczke_klient(96, 1907);
select wloz_paczke_klient(96, 1908);
select wloz_paczke_klient(96, 1909);
select wloz_paczke_klient(96, 1910);
select wloz_paczke_klient(96, 1911);
select wloz_paczke_klient(96, 1912);
select wloz_paczke_klient(96, 1913);
select wloz_paczke_klient(96, 1914);
select wloz_paczke_klient(96, 1915);
select wloz_paczke_klient(96, 1916);
select wloz_paczke_klient(96, 1917);
select wloz_paczke_klient(96, 1918);
select wloz_paczke_klient(96, 1919);
select wloz_paczke_klient(96, 1920);
select wloz_paczke_klient(97, 1921);
select wloz_paczke_klient(97, 1922);
select wloz_paczke_klient(97, 1923);
select wloz_paczke_klient(97, 1924);
select wloz_paczke_klient(97, 1925);
select wloz_paczke_klient(97, 1926);
select wloz_paczke_klient(97, 1927);
select wloz_paczke_klient(97, 1928);
select wloz_paczke_klient(97, 1929);
select wloz_paczke_klient(97, 1930);
select wloz_paczke_klient(97, 1931);
select wloz_paczke_klient(97, 1932);
select wloz_paczke_klient(97, 1933);
select wloz_paczke_klient(97, 1934);
select wloz_paczke_klient(97, 1935);
select wloz_paczke_klient(97, 1936);
select wloz_paczke_klient(97, 1937);
select wloz_paczke_klient(97, 1938);
select wloz_paczke_klient(97, 1939);
select wloz_paczke_klient(97, 1940);
select wloz_paczke_klient(98, 1941);
select wloz_paczke_klient(98, 1942);
select wloz_paczke_klient(98, 1943);
select wloz_paczke_klient(98, 1944);
select wloz_paczke_klient(98, 1945);
select wloz_paczke_klient(98, 1946);
select wloz_paczke_klient(98, 1947);
select wloz_paczke_klient(98, 1948);
select wloz_paczke_klient(98, 1949);
select wloz_paczke_klient(98, 1950);
select wloz_paczke_klient(98, 1951);
select wloz_paczke_klient(98, 1952);
select wloz_paczke_klient(98, 1953);
select wloz_paczke_klient(98, 1954);
select wloz_paczke_klient(98, 1955);
select wloz_paczke_klient(98, 1956);
select wloz_paczke_klient(98, 1957);
select wloz_paczke_klient(98, 1958);
select wloz_paczke_klient(98, 1959);
select wloz_paczke_klient(98, 1960);
select wloz_paczke_klient(99, 1961);
select wloz_paczke_klient(99, 1962);
select wloz_paczke_klient(99, 1963);
select wloz_paczke_klient(99, 1964);
select wloz_paczke_klient(99, 1965);
select wloz_paczke_klient(99, 1966);
select wloz_paczke_klient(99, 1967);
select wloz_paczke_klient(99, 1968);
select wloz_paczke_klient(99, 1969);
select wloz_paczke_klient(99, 1970);
select wloz_paczke_klient(99, 1971);
select wloz_paczke_klient(99, 1972);
select wloz_paczke_klient(99, 1973);
select wloz_paczke_klient(99, 1974);
select wloz_paczke_klient(99, 1975);
select wloz_paczke_klient(99, 1976);
select wloz_paczke_klient(99, 1977);
select wloz_paczke_klient(99, 1978);
select wloz_paczke_klient(99, 1979);
select wloz_paczke_klient(99, 1980);
select wloz_paczke_klient(100, 1981);
select wloz_paczke_klient(100, 1982);
select wloz_paczke_klient(100, 1983);
select wloz_paczke_klient(100, 1984);
select wloz_paczke_klient(100, 1985);
select wloz_paczke_klient(100, 1986);
select wloz_paczke_klient(100, 1987);
select wloz_paczke_klient(100, 1988);
select wloz_paczke_klient(100, 1989);
select wloz_paczke_klient(100, 1990);
select wloz_paczke_klient(100, 1991);
select wloz_paczke_klient(100, 1992);
select wloz_paczke_klient(100, 1993);
select wloz_paczke_klient(100, 1994);
select wloz_paczke_klient(100, 1995);
select wloz_paczke_klient(100, 1996);
select wloz_paczke_klient(100, 1997);
select wloz_paczke_klient(100, 1998);
select wloz_paczke_klient(100, 1999);
select wloz_paczke_klient(100, 2000);


select create_przewoz(1);
select create_przewoz(2);
select create_przewoz(3);
select create_przewoz(4);
select create_przewoz(5);
select create_przewoz(6);
select create_przewoz(7);
select create_przewoz(8);
select create_przewoz(9);
select create_przewoz(10);
select create_przewoz(11);
select create_przewoz(12);
select create_przewoz(13);
select create_przewoz(14);
select create_przewoz(15);
select create_przewoz(16);
select create_przewoz(17);
select create_przewoz(18);
select create_przewoz(19);
select create_przewoz(20);
select create_przewoz(21);
select create_przewoz(22);
select create_przewoz(23);
select create_przewoz(24);
select create_przewoz(25);

select wez_paczki_pracownik(1, 3, 38);
select wez_paczki_pracownik(1, 18, 43);
select wez_paczki_pracownik(1, 38, 8);
select wez_paczki_pracownik(1, 44, 4);
select wez_paczki_pracownik(1, 33, 37);
select wez_paczki_pracownik(1, 19, 49);
select wez_paczki_pracownik(1, 49, 25);
select wez_paczki_pracownik(1, 47, 21);
select wez_paczki_pracownik(1, 37, 50);
select wez_paczki_pracownik(1, 37, 43);
select wez_paczki_pracownik(1, 18, 37);
select wez_paczki_pracownik(1, 32, 23);
select wez_paczki_pracownik(1, 16, 28);
select wez_paczki_pracownik(1, 28, 46);
select wez_paczki_pracownik(1, 19, 8);
select wez_paczki_pracownik(1, 37, 8);
select wez_paczki_pracownik(1, 28, 34);
select wez_paczki_pracownik(1, 50, 12);
select wez_paczki_pracownik(1, 5, 35);
select wez_paczki_pracownik(1, 13, 11);
select wez_paczki_pracownik(2, 46, 48);
select wez_paczki_pracownik(2, 5, 40);
select wez_paczki_pracownik(2, 11, 15);
select wez_paczki_pracownik(2, 47, 27);
select wez_paczki_pracownik(2, 32, 31);
select wez_paczki_pracownik(2, 39, 12);
select wez_paczki_pracownik(2, 13, 28);
select wez_paczki_pracownik(2, 3, 12);
select wez_paczki_pracownik(2, 43, 46);
select wez_paczki_pracownik(2, 3, 10);
select wez_paczki_pracownik(2, 26, 40);
select wez_paczki_pracownik(2, 39, 13);
select wez_paczki_pracownik(2, 5, 13);
select wez_paczki_pracownik(2, 4, 28);
select wez_paczki_pracownik(2, 25, 37);
select wez_paczki_pracownik(2, 37, 6);
select wez_paczki_pracownik(2, 7, 22);
select wez_paczki_pracownik(2, 37, 15);
select wez_paczki_pracownik(2, 24, 21);
select wez_paczki_pracownik(2, 5, 32);
select wez_paczki_pracownik(3, 36, 16);
select wez_paczki_pracownik(3, 14, 2);
select wez_paczki_pracownik(3, 49, 8);
select wez_paczki_pracownik(3, 8, 25);
select wez_paczki_pracownik(3, 41, 12);
select wez_paczki_pracownik(3, 41, 8);
select wez_paczki_pracownik(3, 34, 35);
select wez_paczki_pracownik(3, 21, 25);
select wez_paczki_pracownik(3, 31, 50);
select wez_paczki_pracownik(3, 45, 25);
select wez_paczki_pracownik(3, 34, 50);
select wez_paczki_pracownik(3, 38, 27);
select wez_paczki_pracownik(3, 50, 8);
select wez_paczki_pracownik(3, 40, 48);
select wez_paczki_pracownik(3, 24, 18);
select wez_paczki_pracownik(3, 15, 48);
select wez_paczki_pracownik(3, 13, 20);
select wez_paczki_pracownik(3, 34, 31);
select wez_paczki_pracownik(3, 49, 32);
select wez_paczki_pracownik(3, 48, 47);
select wez_paczki_pracownik(4, 1, 14);
select wez_paczki_pracownik(4, 38, 50);
select wez_paczki_pracownik(4, 48, 9);
select wez_paczki_pracownik(4, 7, 46);
select wez_paczki_pracownik(4, 28, 18);
select wez_paczki_pracownik(4, 19, 15);
select wez_paczki_pracownik(4, 10, 13);
select wez_paczki_pracownik(4, 2, 14);
select wez_paczki_pracownik(4, 42, 4);
select wez_paczki_pracownik(4, 47, 21);
select wez_paczki_pracownik(4, 32, 31);
select wez_paczki_pracownik(4, 11, 2);
select wez_paczki_pracownik(4, 31, 17);
select wez_paczki_pracownik(4, 15, 1);
select wez_paczki_pracownik(4, 2, 12);
select wez_paczki_pracownik(4, 5, 11);
select wez_paczki_pracownik(4, 34, 28);
select wez_paczki_pracownik(4, 18, 39);
select wez_paczki_pracownik(4, 43, 30);
select wez_paczki_pracownik(4, 8, 19);
select wez_paczki_pracownik(5, 28, 27);
select wez_paczki_pracownik(5, 7, 29);
select wez_paczki_pracownik(5, 21, 42);
select wez_paczki_pracownik(5, 22, 14);
select wez_paczki_pracownik(5, 35, 1);
select wez_paczki_pracownik(5, 25, 49);
select wez_paczki_pracownik(5, 47, 28);
select wez_paczki_pracownik(5, 20, 50);
select wez_paczki_pracownik(5, 50, 22);
select wez_paczki_pracownik(5, 34, 15);
select wez_paczki_pracownik(5, 40, 45);
select wez_paczki_pracownik(5, 43, 49);
select wez_paczki_pracownik(5, 9, 41);
select wez_paczki_pracownik(5, 3, 14);
select wez_paczki_pracownik(5, 5, 36);
select wez_paczki_pracownik(5, 36, 46);
select wez_paczki_pracownik(5, 45, 26);
select wez_paczki_pracownik(5, 50, 24);
select wez_paczki_pracownik(5, 18, 39);
select wez_paczki_pracownik(5, 12, 40);
select wez_paczki_pracownik(6, 4, 42);
select wez_paczki_pracownik(6, 33, 23);
select wez_paczki_pracownik(6, 26, 41);
select wez_paczki_pracownik(6, 17, 49);
select wez_paczki_pracownik(6, 24, 36);
select wez_paczki_pracownik(6, 4, 37);
select wez_paczki_pracownik(6, 34, 18);
select wez_paczki_pracownik(6, 19, 21);
select wez_paczki_pracownik(6, 23, 46);
select wez_paczki_pracownik(6, 47, 38);
select wez_paczki_pracownik(6, 32, 3);
select wez_paczki_pracownik(6, 3, 4);
select wez_paczki_pracownik(6, 46, 48);
select wez_paczki_pracownik(6, 32, 50);
select wez_paczki_pracownik(6, 37, 32);
select wez_paczki_pracownik(6, 15, 28);
select wez_paczki_pracownik(6, 39, 31);
select wez_paczki_pracownik(6, 23, 17);
select wez_paczki_pracownik(6, 19, 12);
select wez_paczki_pracownik(6, 21, 32);
select wez_paczki_pracownik(7, 21, 18);
select wez_paczki_pracownik(7, 36, 48);
select wez_paczki_pracownik(7, 21, 17);
select wez_paczki_pracownik(7, 26, 30);
select wez_paczki_pracownik(7, 48, 15);
select wez_paczki_pracownik(7, 22, 5);
select wez_paczki_pracownik(7, 45, 6);
select wez_paczki_pracownik(7, 49, 24);
select wez_paczki_pracownik(7, 45, 23);
select wez_paczki_pracownik(7, 35, 2);
select wez_paczki_pracownik(7, 37, 16);
select wez_paczki_pracownik(7, 9, 17);
select wez_paczki_pracownik(7, 10, 22);
select wez_paczki_pracownik(7, 16, 43);
select wez_paczki_pracownik(7, 46, 26);
select wez_paczki_pracownik(7, 14, 42);
select wez_paczki_pracownik(7, 33, 8);
select wez_paczki_pracownik(7, 42, 26);
select wez_paczki_pracownik(7, 40, 22);
select wez_paczki_pracownik(7, 14, 8);
select wez_paczki_pracownik(8, 35, 36);
select wez_paczki_pracownik(8, 34, 26);
select wez_paczki_pracownik(8, 4, 12);
select wez_paczki_pracownik(8, 24, 48);
select wez_paczki_pracownik(8, 39, 45);
select wez_paczki_pracownik(8, 7, 8);
select wez_paczki_pracownik(8, 40, 42);
select wez_paczki_pracownik(8, 10, 44);
select wez_paczki_pracownik(8, 50, 17);
select wez_paczki_pracownik(8, 39, 6);
select wez_paczki_pracownik(8, 13, 41);
select wez_paczki_pracownik(8, 49, 4);
select wez_paczki_pracownik(8, 17, 20);
select wez_paczki_pracownik(8, 45, 15);
select wez_paczki_pracownik(8, 16, 13);
select wez_paczki_pracownik(8, 11, 24);
select wez_paczki_pracownik(8, 8, 37);
select wez_paczki_pracownik(8, 32, 49);
select wez_paczki_pracownik(8, 42, 50);
select wez_paczki_pracownik(8, 17, 27);
select wez_paczki_pracownik(9, 34, 50);
select wez_paczki_pracownik(9, 19, 49);
select wez_paczki_pracownik(9, 2, 11);
select wez_paczki_pracownik(9, 28, 33);
select wez_paczki_pracownik(9, 4, 10);
select wez_paczki_pracownik(9, 36, 21);
select wez_paczki_pracownik(9, 10, 31);
select wez_paczki_pracownik(9, 35, 43);
select wez_paczki_pracownik(9, 49, 10);
select wez_paczki_pracownik(9, 34, 29);
select wez_paczki_pracownik(9, 48, 20);
select wez_paczki_pracownik(9, 33, 23);
select wez_paczki_pracownik(9, 27, 30);
select wez_paczki_pracownik(9, 41, 1);
select wez_paczki_pracownik(9, 4, 16);
select wez_paczki_pracownik(9, 8, 3);
select wez_paczki_pracownik(9, 23, 35);
select wez_paczki_pracownik(9, 17, 19);
select wez_paczki_pracownik(9, 39, 43);
select wez_paczki_pracownik(9, 42, 36);
select wez_paczki_pracownik(10, 1, 16);
select wez_paczki_pracownik(10, 42, 41);
select wez_paczki_pracownik(10, 18, 31);
select wez_paczki_pracownik(10, 17, 36);
select wez_paczki_pracownik(10, 17, 40);
select wez_paczki_pracownik(10, 12, 36);
select wez_paczki_pracownik(10, 47, 33);
select wez_paczki_pracownik(10, 36, 38);
select wez_paczki_pracownik(10, 7, 11);
select wez_paczki_pracownik(10, 27, 48);
select wez_paczki_pracownik(10, 10, 39);
select wez_paczki_pracownik(10, 36, 46);
select wez_paczki_pracownik(10, 3, 25);
select wez_paczki_pracownik(10, 22, 5);
select wez_paczki_pracownik(10, 35, 25);
select wez_paczki_pracownik(10, 38, 40);
select wez_paczki_pracownik(10, 19, 50);
select wez_paczki_pracownik(10, 25, 3);
select wez_paczki_pracownik(10, 47, 39);
select wez_paczki_pracownik(10, 8, 37);
select wez_paczki_pracownik(11, 15, 24);
select wez_paczki_pracownik(11, 7, 20);
select wez_paczki_pracownik(11, 39, 32);
select wez_paczki_pracownik(11, 44, 46);
select wez_paczki_pracownik(11, 18, 10);
select wez_paczki_pracownik(11, 23, 50);
select wez_paczki_pracownik(11, 18, 32);
select wez_paczki_pracownik(11, 19, 37);
select wez_paczki_pracownik(11, 35, 33);
select wez_paczki_pracownik(11, 23, 14);
select wez_paczki_pracownik(11, 48, 37);
select wez_paczki_pracownik(11, 45, 49);
select wez_paczki_pracownik(11, 46, 14);
select wez_paczki_pracownik(11, 41, 13);
select wez_paczki_pracownik(11, 42, 11);
select wez_paczki_pracownik(11, 17, 32);
select wez_paczki_pracownik(11, 40, 23);
select wez_paczki_pracownik(11, 14, 13);
select wez_paczki_pracownik(11, 30, 10);
select wez_paczki_pracownik(11, 44, 14);
select wez_paczki_pracownik(12, 2, 33);
select wez_paczki_pracownik(12, 5, 38);
select wez_paczki_pracownik(12, 7, 34);
select wez_paczki_pracownik(12, 9, 13);
select wez_paczki_pracownik(12, 40, 18);
select wez_paczki_pracownik(12, 37, 40);
select wez_paczki_pracownik(12, 15, 40);
select wez_paczki_pracownik(12, 24, 44);
select wez_paczki_pracownik(12, 42, 7);
select wez_paczki_pracownik(12, 18, 10);
select wez_paczki_pracownik(12, 7, 44);
select wez_paczki_pracownik(12, 7, 24);
select wez_paczki_pracownik(12, 14, 6);
select wez_paczki_pracownik(12, 1, 32);
select wez_paczki_pracownik(12, 43, 26);
select wez_paczki_pracownik(12, 35, 12);
select wez_paczki_pracownik(12, 25, 22);
select wez_paczki_pracownik(12, 11, 25);
select wez_paczki_pracownik(12, 29, 3);
select wez_paczki_pracownik(12, 20, 18);
select wez_paczki_pracownik(13, 12, 27);
select wez_paczki_pracownik(13, 48, 8);
select wez_paczki_pracownik(13, 6, 3);
select wez_paczki_pracownik(13, 27, 47);
select wez_paczki_pracownik(13, 33, 34);
select wez_paczki_pracownik(13, 31, 9);
select wez_paczki_pracownik(13, 38, 42);
select wez_paczki_pracownik(13, 29, 38);
select wez_paczki_pracownik(13, 8, 13);
select wez_paczki_pracownik(13, 39, 37);
select wez_paczki_pracownik(13, 23, 1);
select wez_paczki_pracownik(13, 47, 28);
select wez_paczki_pracownik(13, 21, 7);
select wez_paczki_pracownik(13, 7, 21);
select wez_paczki_pracownik(13, 6, 34);
select wez_paczki_pracownik(13, 31, 3);
select wez_paczki_pracownik(13, 46, 48);
select wez_paczki_pracownik(13, 20, 25);
select wez_paczki_pracownik(13, 36, 27);
select wez_paczki_pracownik(13, 44, 15);
select wez_paczki_pracownik(14, 26, 41);
select wez_paczki_pracownik(14, 29, 13);
select wez_paczki_pracownik(14, 13, 26);
select wez_paczki_pracownik(14, 49, 12);
select wez_paczki_pracownik(14, 27, 29);
select wez_paczki_pracownik(14, 10, 31);
select wez_paczki_pracownik(14, 14, 15);
select wez_paczki_pracownik(14, 46, 25);
select wez_paczki_pracownik(14, 31, 24);
select wez_paczki_pracownik(14, 42, 22);
select wez_paczki_pracownik(14, 27, 44);
select wez_paczki_pracownik(14, 32, 8);
select wez_paczki_pracownik(14, 20, 14);
select wez_paczki_pracownik(14, 10, 35);
select wez_paczki_pracownik(14, 48, 11);
select wez_paczki_pracownik(14, 15, 22);
select wez_paczki_pracownik(14, 2, 21);
select wez_paczki_pracownik(14, 43, 10);
select wez_paczki_pracownik(14, 17, 11);
select wez_paczki_pracownik(14, 40, 11);
select wez_paczki_pracownik(15, 32, 46);
select wez_paczki_pracownik(15, 24, 2);
select wez_paczki_pracownik(15, 18, 25);
select wez_paczki_pracownik(15, 48, 22);
select wez_paczki_pracownik(15, 46, 30);
select wez_paczki_pracownik(15, 10, 22);
select wez_paczki_pracownik(15, 33, 41);
select wez_paczki_pracownik(15, 49, 48);
select wez_paczki_pracownik(15, 23, 19);
select wez_paczki_pracownik(15, 15, 36);
select wez_paczki_pracownik(15, 27, 18);
select wez_paczki_pracownik(15, 34, 5);
select wez_paczki_pracownik(15, 12, 7);
select wez_paczki_pracownik(15, 30, 44);
select wez_paczki_pracownik(15, 6, 30);
select wez_paczki_pracownik(15, 14, 46);
select wez_paczki_pracownik(15, 44, 40);
select wez_paczki_pracownik(15, 5, 6);
select wez_paczki_pracownik(15, 14, 7);
select wez_paczki_pracownik(15, 8, 50);
select wez_paczki_pracownik(16, 25, 28);
select wez_paczki_pracownik(16, 7, 37);
select wez_paczki_pracownik(16, 43, 42);
select wez_paczki_pracownik(16, 29, 50);
select wez_paczki_pracownik(16, 15, 27);
select wez_paczki_pracownik(16, 17, 24);
select wez_paczki_pracownik(16, 45, 13);
select wez_paczki_pracownik(16, 10, 20);
select wez_paczki_pracownik(16, 31, 14);
select wez_paczki_pracownik(16, 15, 23);
select wez_paczki_pracownik(16, 26, 43);
select wez_paczki_pracownik(16, 17, 42);
select wez_paczki_pracownik(16, 14, 7);
select wez_paczki_pracownik(16, 14, 27);
select wez_paczki_pracownik(16, 32, 42);
select wez_paczki_pracownik(16, 49, 33);
select wez_paczki_pracownik(16, 14, 30);
select wez_paczki_pracownik(16, 16, 26);
select wez_paczki_pracownik(16, 41, 37);
select wez_paczki_pracownik(16, 14, 37);
select wez_paczki_pracownik(17, 35, 41);
select wez_paczki_pracownik(17, 43, 36);
select wez_paczki_pracownik(17, 41, 44);
select wez_paczki_pracownik(17, 39, 33);
select wez_paczki_pracownik(17, 22, 43);
select wez_paczki_pracownik(17, 26, 15);
select wez_paczki_pracownik(17, 21, 28);
select wez_paczki_pracownik(17, 38, 7);
select wez_paczki_pracownik(17, 32, 1);
select wez_paczki_pracownik(17, 3, 41);
select wez_paczki_pracownik(17, 19, 30);
select wez_paczki_pracownik(17, 43, 5);
select wez_paczki_pracownik(17, 20, 23);
select wez_paczki_pracownik(17, 45, 36);
select wez_paczki_pracownik(17, 30, 22);
select wez_paczki_pracownik(17, 32, 25);
select wez_paczki_pracownik(17, 3, 13);
select wez_paczki_pracownik(17, 24, 5);
select wez_paczki_pracownik(17, 7, 16);
select wez_paczki_pracownik(17, 3, 13);
select wez_paczki_pracownik(18, 20, 5);
select wez_paczki_pracownik(18, 29, 8);
select wez_paczki_pracownik(18, 9, 27);
select wez_paczki_pracownik(18, 39, 48);
select wez_paczki_pracownik(18, 14, 38);
select wez_paczki_pracownik(18, 14, 15);
select wez_paczki_pracownik(18, 43, 7);
select wez_paczki_pracownik(18, 24, 12);
select wez_paczki_pracownik(18, 46, 45);
select wez_paczki_pracownik(18, 5, 11);
select wez_paczki_pracownik(18, 2, 7);
select wez_paczki_pracownik(18, 14, 42);
select wez_paczki_pracownik(18, 23, 15);
select wez_paczki_pracownik(18, 47, 27);
select wez_paczki_pracownik(18, 11, 19);
select wez_paczki_pracownik(18, 41, 7);
select wez_paczki_pracownik(18, 16, 17);
select wez_paczki_pracownik(18, 28, 48);
select wez_paczki_pracownik(18, 15, 14);
select wez_paczki_pracownik(18, 45, 37);
select wez_paczki_pracownik(19, 39, 12);
select wez_paczki_pracownik(19, 40, 15);
select wez_paczki_pracownik(19, 4, 41);
select wez_paczki_pracownik(19, 4, 50);
select wez_paczki_pracownik(19, 22, 40);
select wez_paczki_pracownik(19, 6, 9);
select wez_paczki_pracownik(19, 19, 8);
select wez_paczki_pracownik(19, 14, 22);
select wez_paczki_pracownik(19, 1, 4);
select wez_paczki_pracownik(19, 20, 49);
select wez_paczki_pracownik(19, 6, 25);
select wez_paczki_pracownik(19, 20, 17);
select wez_paczki_pracownik(19, 35, 43);
select wez_paczki_pracownik(19, 50, 4);
select wez_paczki_pracownik(19, 6, 19);
select wez_paczki_pracownik(19, 10, 36);
select wez_paczki_pracownik(19, 21, 37);
select wez_paczki_pracownik(19, 32, 36);
select wez_paczki_pracownik(19, 25, 38);
select wez_paczki_pracownik(19, 11, 36);
select wez_paczki_pracownik(20, 49, 29);
select wez_paczki_pracownik(20, 45, 20);
select wez_paczki_pracownik(20, 49, 1);
select wez_paczki_pracownik(20, 14, 9);
select wez_paczki_pracownik(20, 43, 16);
select wez_paczki_pracownik(20, 30, 24);
select wez_paczki_pracownik(20, 38, 24);
select wez_paczki_pracownik(20, 40, 42);
select wez_paczki_pracownik(20, 19, 37);
select wez_paczki_pracownik(20, 8, 37);
select wez_paczki_pracownik(20, 25, 15);
select wez_paczki_pracownik(20, 33, 26);
select wez_paczki_pracownik(20, 26, 5);
select wez_paczki_pracownik(20, 32, 1);
select wez_paczki_pracownik(20, 14, 18);
select wez_paczki_pracownik(20, 7, 16);
select wez_paczki_pracownik(20, 12, 7);
select wez_paczki_pracownik(20, 18, 11);
select wez_paczki_pracownik(20, 16, 46);
select wez_paczki_pracownik(20, 5, 21);
select wez_paczki_pracownik(21, 37, 25);
select wez_paczki_pracownik(21, 44, 23);
select wez_paczki_pracownik(21, 8, 40);
select wez_paczki_pracownik(21, 50, 3);
select wez_paczki_pracownik(21, 7, 23);
select wez_paczki_pracownik(21, 44, 19);
select wez_paczki_pracownik(21, 30, 7);
select wez_paczki_pracownik(21, 8, 32);
select wez_paczki_pracownik(21, 8, 37);
select wez_paczki_pracownik(21, 35, 48);
select wez_paczki_pracownik(21, 32, 44);
select wez_paczki_pracownik(21, 39, 8);
select wez_paczki_pracownik(21, 24, 35);
select wez_paczki_pracownik(21, 41, 1);
select wez_paczki_pracownik(21, 45, 9);
select wez_paczki_pracownik(21, 47, 36);
select wez_paczki_pracownik(21, 27, 30);
select wez_paczki_pracownik(21, 16, 27);
select wez_paczki_pracownik(21, 47, 13);
select wez_paczki_pracownik(21, 9, 8);
select wez_paczki_pracownik(22, 11, 46);
select wez_paczki_pracownik(22, 2, 44);
select wez_paczki_pracownik(22, 49, 39);
select wez_paczki_pracownik(22, 47, 36);
select wez_paczki_pracownik(22, 18, 11);
select wez_paczki_pracownik(22, 22, 1);
select wez_paczki_pracownik(22, 18, 12);
select wez_paczki_pracownik(22, 44, 27);
select wez_paczki_pracownik(22, 29, 5);
select wez_paczki_pracownik(22, 50, 44);
select wez_paczki_pracownik(22, 17, 34);
select wez_paczki_pracownik(22, 46, 3);
select wez_paczki_pracownik(22, 5, 4);
select wez_paczki_pracownik(22, 37, 31);
select wez_paczki_pracownik(22, 44, 15);
select wez_paczki_pracownik(22, 5, 14);
select wez_paczki_pracownik(22, 19, 31);
select wez_paczki_pracownik(22, 27, 19);
select wez_paczki_pracownik(22, 28, 16);
select wez_paczki_pracownik(22, 13, 3);
select wez_paczki_pracownik(23, 28, 45);
select wez_paczki_pracownik(23, 39, 47);
select wez_paczki_pracownik(23, 18, 25);
select wez_paczki_pracownik(23, 5, 8);
select wez_paczki_pracownik(23, 6, 18);
select wez_paczki_pracownik(23, 21, 35);
select wez_paczki_pracownik(23, 4, 33);
select wez_paczki_pracownik(23, 47, 19);
select wez_paczki_pracownik(23, 18, 16);
select wez_paczki_pracownik(23, 37, 2);
select wez_paczki_pracownik(23, 42, 23);
select wez_paczki_pracownik(23, 11, 5);
select wez_paczki_pracownik(23, 36, 2);
select wez_paczki_pracownik(23, 33, 15);
select wez_paczki_pracownik(23, 31, 7);
select wez_paczki_pracownik(23, 7, 44);
select wez_paczki_pracownik(23, 18, 41);
select wez_paczki_pracownik(23, 29, 9);
select wez_paczki_pracownik(23, 9, 4);
select wez_paczki_pracownik(23, 8, 21);
select wez_paczki_pracownik(24, 48, 46);
select wez_paczki_pracownik(24, 6, 45);
select wez_paczki_pracownik(24, 43, 36);
select wez_paczki_pracownik(24, 10, 40);
select wez_paczki_pracownik(24, 27, 11);
select wez_paczki_pracownik(24, 46, 2);
select wez_paczki_pracownik(24, 27, 38);
select wez_paczki_pracownik(24, 11, 36);
select wez_paczki_pracownik(24, 45, 32);
select wez_paczki_pracownik(24, 39, 10);
select wez_paczki_pracownik(24, 35, 23);
select wez_paczki_pracownik(24, 9, 29);
select wez_paczki_pracownik(24, 22, 10);
select wez_paczki_pracownik(24, 18, 25);
select wez_paczki_pracownik(24, 21, 23);
select wez_paczki_pracownik(24, 18, 30);
select wez_paczki_pracownik(24, 16, 39);
select wez_paczki_pracownik(24, 23, 47);
select wez_paczki_pracownik(24, 18, 7);
select wez_paczki_pracownik(24, 41, 27);
select wez_paczki_pracownik(25, 18, 39);
select wez_paczki_pracownik(25, 40, 44);
select wez_paczki_pracownik(25, 8, 48);
select wez_paczki_pracownik(25, 40, 6);
select wez_paczki_pracownik(25, 23, 9);
select wez_paczki_pracownik(25, 36, 6);
select wez_paczki_pracownik(25, 44, 2);
select wez_paczki_pracownik(25, 24, 2);
select wez_paczki_pracownik(25, 43, 4);
select wez_paczki_pracownik(25, 41, 16);
select wez_paczki_pracownik(25, 11, 41);
select wez_paczki_pracownik(25, 40, 39);
select wez_paczki_pracownik(25, 17, 36);
select wez_paczki_pracownik(25, 15, 17);
select wez_paczki_pracownik(25, 36, 8);
select wez_paczki_pracownik(25, 1, 47);
select wez_paczki_pracownik(25, 50, 38);
select wez_paczki_pracownik(25, 44, 32);
select wez_paczki_pracownik(25, 24, 32);
select wez_paczki_pracownik(25, 48, 14);

select wloz_paczki_pracownik(1, 1);
select wloz_paczki_pracownik(1, 2);
select wloz_paczki_pracownik(1, 3);
select wloz_paczki_pracownik(1, 4);
select wloz_paczki_pracownik(1, 5);
select wloz_paczki_pracownik(1, 6);
select wloz_paczki_pracownik(1, 7);
select wloz_paczki_pracownik(1, 8);
select wloz_paczki_pracownik(1, 9);
select wloz_paczki_pracownik(1, 10);
select wloz_paczki_pracownik(1, 11);
select wloz_paczki_pracownik(1, 12);
select wloz_paczki_pracownik(1, 13);
select wloz_paczki_pracownik(1, 14);
select wloz_paczki_pracownik(1, 15);
select wloz_paczki_pracownik(1, 16);
select wloz_paczki_pracownik(1, 17);
select wloz_paczki_pracownik(1, 18);
select wloz_paczki_pracownik(1, 19);
select wloz_paczki_pracownik(1, 20);
select wloz_paczki_pracownik(1, 21);
select wloz_paczki_pracownik(1, 22);
select wloz_paczki_pracownik(1, 23);
select wloz_paczki_pracownik(1, 24);
select wloz_paczki_pracownik(1, 25);
select wloz_paczki_pracownik(1, 26);
select wloz_paczki_pracownik(1, 27);
select wloz_paczki_pracownik(1, 28);
select wloz_paczki_pracownik(1, 29);
select wloz_paczki_pracownik(1, 30);
select wloz_paczki_pracownik(1, 31);
select wloz_paczki_pracownik(1, 32);
select wloz_paczki_pracownik(1, 33);
select wloz_paczki_pracownik(1, 34);
select wloz_paczki_pracownik(1, 35);
select wloz_paczki_pracownik(1, 36);
select wloz_paczki_pracownik(1, 37);
select wloz_paczki_pracownik(1, 38);
select wloz_paczki_pracownik(1, 39);
select wloz_paczki_pracownik(1, 40);
select wloz_paczki_pracownik(2, 1);
select wloz_paczki_pracownik(2, 2);
select wloz_paczki_pracownik(2, 3);
select wloz_paczki_pracownik(2, 4);
select wloz_paczki_pracownik(2, 5);
select wloz_paczki_pracownik(2, 6);
select wloz_paczki_pracownik(2, 7);
select wloz_paczki_pracownik(2, 8);
select wloz_paczki_pracownik(2, 9);
select wloz_paczki_pracownik(2, 10);
select wloz_paczki_pracownik(2, 11);
select wloz_paczki_pracownik(2, 12);
select wloz_paczki_pracownik(2, 13);
select wloz_paczki_pracownik(2, 14);
select wloz_paczki_pracownik(2, 15);
select wloz_paczki_pracownik(2, 16);
select wloz_paczki_pracownik(2, 17);
select wloz_paczki_pracownik(2, 18);
select wloz_paczki_pracownik(2, 19);
select wloz_paczki_pracownik(2, 20);
select wloz_paczki_pracownik(2, 21);
select wloz_paczki_pracownik(2, 22);
select wloz_paczki_pracownik(2, 23);
select wloz_paczki_pracownik(2, 24);
select wloz_paczki_pracownik(2, 25);
select wloz_paczki_pracownik(2, 26);
select wloz_paczki_pracownik(2, 27);
select wloz_paczki_pracownik(2, 28);
select wloz_paczki_pracownik(2, 29);
select wloz_paczki_pracownik(2, 30);
select wloz_paczki_pracownik(2, 31);
select wloz_paczki_pracownik(2, 32);
select wloz_paczki_pracownik(2, 33);
select wloz_paczki_pracownik(2, 34);
select wloz_paczki_pracownik(2, 35);
select wloz_paczki_pracownik(2, 36);
select wloz_paczki_pracownik(2, 37);
select wloz_paczki_pracownik(2, 38);
select wloz_paczki_pracownik(2, 39);
select wloz_paczki_pracownik(2, 40);
select wloz_paczki_pracownik(3, 1);
select wloz_paczki_pracownik(3, 2);
select wloz_paczki_pracownik(3, 3);
select wloz_paczki_pracownik(3, 4);
select wloz_paczki_pracownik(3, 5);
select wloz_paczki_pracownik(3, 6);
select wloz_paczki_pracownik(3, 7);
select wloz_paczki_pracownik(3, 8);
select wloz_paczki_pracownik(3, 9);
select wloz_paczki_pracownik(3, 10);
select wloz_paczki_pracownik(3, 11);
select wloz_paczki_pracownik(3, 12);
select wloz_paczki_pracownik(3, 13);
select wloz_paczki_pracownik(3, 14);
select wloz_paczki_pracownik(3, 15);
select wloz_paczki_pracownik(3, 16);
select wloz_paczki_pracownik(3, 17);
select wloz_paczki_pracownik(3, 18);
select wloz_paczki_pracownik(3, 19);
select wloz_paczki_pracownik(3, 20);
select wloz_paczki_pracownik(3, 21);
select wloz_paczki_pracownik(3, 22);
select wloz_paczki_pracownik(3, 23);
select wloz_paczki_pracownik(3, 24);
select wloz_paczki_pracownik(3, 25);
select wloz_paczki_pracownik(3, 26);
select wloz_paczki_pracownik(3, 27);
select wloz_paczki_pracownik(3, 28);
select wloz_paczki_pracownik(3, 29);
select wloz_paczki_pracownik(3, 30);
select wloz_paczki_pracownik(3, 31);
select wloz_paczki_pracownik(3, 32);
select wloz_paczki_pracownik(3, 33);
select wloz_paczki_pracownik(3, 34);
select wloz_paczki_pracownik(3, 35);
select wloz_paczki_pracownik(3, 36);
select wloz_paczki_pracownik(3, 37);
select wloz_paczki_pracownik(3, 38);
select wloz_paczki_pracownik(3, 39);
select wloz_paczki_pracownik(3, 40);
select wloz_paczki_pracownik(4, 1);
select wloz_paczki_pracownik(4, 2);
select wloz_paczki_pracownik(4, 3);
select wloz_paczki_pracownik(4, 4);
select wloz_paczki_pracownik(4, 5);
select wloz_paczki_pracownik(4, 6);
select wloz_paczki_pracownik(4, 7);
select wloz_paczki_pracownik(4, 8);
select wloz_paczki_pracownik(4, 9);
select wloz_paczki_pracownik(4, 10);
select wloz_paczki_pracownik(4, 11);
select wloz_paczki_pracownik(4, 12);
select wloz_paczki_pracownik(4, 13);
select wloz_paczki_pracownik(4, 14);
select wloz_paczki_pracownik(4, 15);
select wloz_paczki_pracownik(4, 16);
select wloz_paczki_pracownik(4, 17);
select wloz_paczki_pracownik(4, 18);
select wloz_paczki_pracownik(4, 19);
select wloz_paczki_pracownik(4, 20);
select wloz_paczki_pracownik(4, 21);
select wloz_paczki_pracownik(4, 22);
select wloz_paczki_pracownik(4, 23);
select wloz_paczki_pracownik(4, 24);
select wloz_paczki_pracownik(4, 25);
select wloz_paczki_pracownik(4, 26);
select wloz_paczki_pracownik(4, 27);
select wloz_paczki_pracownik(4, 28);
select wloz_paczki_pracownik(4, 29);
select wloz_paczki_pracownik(4, 30);
select wloz_paczki_pracownik(4, 31);
select wloz_paczki_pracownik(4, 32);
select wloz_paczki_pracownik(4, 33);
select wloz_paczki_pracownik(4, 34);
select wloz_paczki_pracownik(4, 35);
select wloz_paczki_pracownik(4, 36);
select wloz_paczki_pracownik(4, 37);
select wloz_paczki_pracownik(4, 38);
select wloz_paczki_pracownik(4, 39);
select wloz_paczki_pracownik(4, 40);
select wloz_paczki_pracownik(5, 1);
select wloz_paczki_pracownik(5, 2);
select wloz_paczki_pracownik(5, 3);
select wloz_paczki_pracownik(5, 4);
select wloz_paczki_pracownik(5, 5);
select wloz_paczki_pracownik(5, 6);
select wloz_paczki_pracownik(5, 7);
select wloz_paczki_pracownik(5, 8);
select wloz_paczki_pracownik(5, 9);
select wloz_paczki_pracownik(5, 10);
select wloz_paczki_pracownik(5, 11);
select wloz_paczki_pracownik(5, 12);
select wloz_paczki_pracownik(5, 13);
select wloz_paczki_pracownik(5, 14);
select wloz_paczki_pracownik(5, 15);
select wloz_paczki_pracownik(5, 16);
select wloz_paczki_pracownik(5, 17);
select wloz_paczki_pracownik(5, 18);
select wloz_paczki_pracownik(5, 19);
select wloz_paczki_pracownik(5, 20);
select wloz_paczki_pracownik(5, 21);
select wloz_paczki_pracownik(5, 22);
select wloz_paczki_pracownik(5, 23);
select wloz_paczki_pracownik(5, 24);
select wloz_paczki_pracownik(5, 25);
select wloz_paczki_pracownik(5, 26);
select wloz_paczki_pracownik(5, 27);
select wloz_paczki_pracownik(5, 28);
select wloz_paczki_pracownik(5, 29);
select wloz_paczki_pracownik(5, 30);
select wloz_paczki_pracownik(5, 31);
select wloz_paczki_pracownik(5, 32);
select wloz_paczki_pracownik(5, 33);
select wloz_paczki_pracownik(5, 34);
select wloz_paczki_pracownik(5, 35);
select wloz_paczki_pracownik(5, 36);
select wloz_paczki_pracownik(5, 37);
select wloz_paczki_pracownik(5, 38);
select wloz_paczki_pracownik(5, 39);
select wloz_paczki_pracownik(5, 40);
select wloz_paczki_pracownik(6, 1);
select wloz_paczki_pracownik(6, 2);
select wloz_paczki_pracownik(6, 3);
select wloz_paczki_pracownik(6, 4);
select wloz_paczki_pracownik(6, 5);
select wloz_paczki_pracownik(6, 6);
select wloz_paczki_pracownik(6, 7);
select wloz_paczki_pracownik(6, 8);
select wloz_paczki_pracownik(6, 9);
select wloz_paczki_pracownik(6, 10);
select wloz_paczki_pracownik(6, 11);
select wloz_paczki_pracownik(6, 12);
select wloz_paczki_pracownik(6, 13);
select wloz_paczki_pracownik(6, 14);
select wloz_paczki_pracownik(6, 15);
select wloz_paczki_pracownik(6, 16);
select wloz_paczki_pracownik(6, 17);
select wloz_paczki_pracownik(6, 18);
select wloz_paczki_pracownik(6, 19);
select wloz_paczki_pracownik(6, 20);
select wloz_paczki_pracownik(6, 21);
select wloz_paczki_pracownik(6, 22);
select wloz_paczki_pracownik(6, 23);
select wloz_paczki_pracownik(6, 24);
select wloz_paczki_pracownik(6, 25);
select wloz_paczki_pracownik(6, 26);
select wloz_paczki_pracownik(6, 27);
select wloz_paczki_pracownik(6, 28);
select wloz_paczki_pracownik(6, 29);
select wloz_paczki_pracownik(6, 30);
select wloz_paczki_pracownik(6, 31);
select wloz_paczki_pracownik(6, 32);
select wloz_paczki_pracownik(6, 33);
select wloz_paczki_pracownik(6, 34);
select wloz_paczki_pracownik(6, 35);
select wloz_paczki_pracownik(6, 36);
select wloz_paczki_pracownik(6, 37);
select wloz_paczki_pracownik(6, 38);
select wloz_paczki_pracownik(6, 39);
select wloz_paczki_pracownik(6, 40);
select wloz_paczki_pracownik(7, 1);
select wloz_paczki_pracownik(7, 2);
select wloz_paczki_pracownik(7, 3);
select wloz_paczki_pracownik(7, 4);
select wloz_paczki_pracownik(7, 5);
select wloz_paczki_pracownik(7, 6);
select wloz_paczki_pracownik(7, 7);
select wloz_paczki_pracownik(7, 8);
select wloz_paczki_pracownik(7, 9);
select wloz_paczki_pracownik(7, 10);
select wloz_paczki_pracownik(7, 11);
select wloz_paczki_pracownik(7, 12);
select wloz_paczki_pracownik(7, 13);
select wloz_paczki_pracownik(7, 14);
select wloz_paczki_pracownik(7, 15);
select wloz_paczki_pracownik(7, 16);
select wloz_paczki_pracownik(7, 17);
select wloz_paczki_pracownik(7, 18);
select wloz_paczki_pracownik(7, 19);
select wloz_paczki_pracownik(7, 20);
select wloz_paczki_pracownik(7, 21);
select wloz_paczki_pracownik(7, 22);
select wloz_paczki_pracownik(7, 23);
select wloz_paczki_pracownik(7, 24);
select wloz_paczki_pracownik(7, 25);
select wloz_paczki_pracownik(7, 26);
select wloz_paczki_pracownik(7, 27);
select wloz_paczki_pracownik(7, 28);
select wloz_paczki_pracownik(7, 29);
select wloz_paczki_pracownik(7, 30);
select wloz_paczki_pracownik(7, 31);
select wloz_paczki_pracownik(7, 32);
select wloz_paczki_pracownik(7, 33);
select wloz_paczki_pracownik(7, 34);
select wloz_paczki_pracownik(7, 35);
select wloz_paczki_pracownik(7, 36);
select wloz_paczki_pracownik(7, 37);
select wloz_paczki_pracownik(7, 38);
select wloz_paczki_pracownik(7, 39);
select wloz_paczki_pracownik(7, 40);
select wloz_paczki_pracownik(8, 1);
select wloz_paczki_pracownik(8, 2);
select wloz_paczki_pracownik(8, 3);
select wloz_paczki_pracownik(8, 4);
select wloz_paczki_pracownik(8, 5);
select wloz_paczki_pracownik(8, 6);
select wloz_paczki_pracownik(8, 7);
select wloz_paczki_pracownik(8, 8);
select wloz_paczki_pracownik(8, 9);
select wloz_paczki_pracownik(8, 10);
select wloz_paczki_pracownik(8, 11);
select wloz_paczki_pracownik(8, 12);
select wloz_paczki_pracownik(8, 13);
select wloz_paczki_pracownik(8, 14);
select wloz_paczki_pracownik(8, 15);
select wloz_paczki_pracownik(8, 16);
select wloz_paczki_pracownik(8, 17);
select wloz_paczki_pracownik(8, 18);
select wloz_paczki_pracownik(8, 19);
select wloz_paczki_pracownik(8, 20);
select wloz_paczki_pracownik(8, 21);
select wloz_paczki_pracownik(8, 22);
select wloz_paczki_pracownik(8, 23);
select wloz_paczki_pracownik(8, 24);
select wloz_paczki_pracownik(8, 25);
select wloz_paczki_pracownik(8, 26);
select wloz_paczki_pracownik(8, 27);
select wloz_paczki_pracownik(8, 28);
select wloz_paczki_pracownik(8, 29);
select wloz_paczki_pracownik(8, 30);
select wloz_paczki_pracownik(8, 31);
select wloz_paczki_pracownik(8, 32);
select wloz_paczki_pracownik(8, 33);
select wloz_paczki_pracownik(8, 34);
select wloz_paczki_pracownik(8, 35);
select wloz_paczki_pracownik(8, 36);
select wloz_paczki_pracownik(8, 37);
select wloz_paczki_pracownik(8, 38);
select wloz_paczki_pracownik(8, 39);
select wloz_paczki_pracownik(8, 40);
select wloz_paczki_pracownik(9, 1);
select wloz_paczki_pracownik(9, 2);
select wloz_paczki_pracownik(9, 3);
select wloz_paczki_pracownik(9, 4);
select wloz_paczki_pracownik(9, 5);
select wloz_paczki_pracownik(9, 6);
select wloz_paczki_pracownik(9, 7);
select wloz_paczki_pracownik(9, 8);
select wloz_paczki_pracownik(9, 9);
select wloz_paczki_pracownik(9, 10);
select wloz_paczki_pracownik(9, 11);
select wloz_paczki_pracownik(9, 12);
select wloz_paczki_pracownik(9, 13);
select wloz_paczki_pracownik(9, 14);
select wloz_paczki_pracownik(9, 15);
select wloz_paczki_pracownik(9, 16);
select wloz_paczki_pracownik(9, 17);
select wloz_paczki_pracownik(9, 18);
select wloz_paczki_pracownik(9, 19);
select wloz_paczki_pracownik(9, 20);
select wloz_paczki_pracownik(9, 21);
select wloz_paczki_pracownik(9, 22);
select wloz_paczki_pracownik(9, 23);
select wloz_paczki_pracownik(9, 24);
select wloz_paczki_pracownik(9, 25);
select wloz_paczki_pracownik(9, 26);
select wloz_paczki_pracownik(9, 27);
select wloz_paczki_pracownik(9, 28);
select wloz_paczki_pracownik(9, 29);
select wloz_paczki_pracownik(9, 30);
select wloz_paczki_pracownik(9, 31);
select wloz_paczki_pracownik(9, 32);
select wloz_paczki_pracownik(9, 33);
select wloz_paczki_pracownik(9, 34);
select wloz_paczki_pracownik(9, 35);
select wloz_paczki_pracownik(9, 36);
select wloz_paczki_pracownik(9, 37);
select wloz_paczki_pracownik(9, 38);
select wloz_paczki_pracownik(9, 39);
select wloz_paczki_pracownik(9, 40);
select wloz_paczki_pracownik(10, 1);
select wloz_paczki_pracownik(10, 2);
select wloz_paczki_pracownik(10, 3);
select wloz_paczki_pracownik(10, 4);
select wloz_paczki_pracownik(10, 5);
select wloz_paczki_pracownik(10, 6);
select wloz_paczki_pracownik(10, 7);
select wloz_paczki_pracownik(10, 8);
select wloz_paczki_pracownik(10, 9);
select wloz_paczki_pracownik(10, 10);
select wloz_paczki_pracownik(10, 11);
select wloz_paczki_pracownik(10, 12);
select wloz_paczki_pracownik(10, 13);
select wloz_paczki_pracownik(10, 14);
select wloz_paczki_pracownik(10, 15);
select wloz_paczki_pracownik(10, 16);
select wloz_paczki_pracownik(10, 17);
select wloz_paczki_pracownik(10, 18);
select wloz_paczki_pracownik(10, 19);
select wloz_paczki_pracownik(10, 20);
select wloz_paczki_pracownik(10, 21);
select wloz_paczki_pracownik(10, 22);
select wloz_paczki_pracownik(10, 23);
select wloz_paczki_pracownik(10, 24);
select wloz_paczki_pracownik(10, 25);
select wloz_paczki_pracownik(10, 26);
select wloz_paczki_pracownik(10, 27);
select wloz_paczki_pracownik(10, 28);
select wloz_paczki_pracownik(10, 29);
select wloz_paczki_pracownik(10, 30);
select wloz_paczki_pracownik(10, 31);
select wloz_paczki_pracownik(10, 32);
select wloz_paczki_pracownik(10, 33);
select wloz_paczki_pracownik(10, 34);
select wloz_paczki_pracownik(10, 35);
select wloz_paczki_pracownik(10, 36);
select wloz_paczki_pracownik(10, 37);
select wloz_paczki_pracownik(10, 38);
select wloz_paczki_pracownik(10, 39);
select wloz_paczki_pracownik(10, 40);
select wloz_paczki_pracownik(11, 1);
select wloz_paczki_pracownik(11, 2);
select wloz_paczki_pracownik(11, 3);
select wloz_paczki_pracownik(11, 4);
select wloz_paczki_pracownik(11, 5);
select wloz_paczki_pracownik(11, 6);
select wloz_paczki_pracownik(11, 7);
select wloz_paczki_pracownik(11, 8);
select wloz_paczki_pracownik(11, 9);
select wloz_paczki_pracownik(11, 10);
select wloz_paczki_pracownik(11, 11);
select wloz_paczki_pracownik(11, 12);
select wloz_paczki_pracownik(11, 13);
select wloz_paczki_pracownik(11, 14);
select wloz_paczki_pracownik(11, 15);
select wloz_paczki_pracownik(11, 16);
select wloz_paczki_pracownik(11, 17);
select wloz_paczki_pracownik(11, 18);
select wloz_paczki_pracownik(11, 19);
select wloz_paczki_pracownik(11, 20);
select wloz_paczki_pracownik(11, 21);
select wloz_paczki_pracownik(11, 22);
select wloz_paczki_pracownik(11, 23);
select wloz_paczki_pracownik(11, 24);
select wloz_paczki_pracownik(11, 25);
select wloz_paczki_pracownik(11, 26);
select wloz_paczki_pracownik(11, 27);
select wloz_paczki_pracownik(11, 28);
select wloz_paczki_pracownik(11, 29);
select wloz_paczki_pracownik(11, 30);
select wloz_paczki_pracownik(11, 31);
select wloz_paczki_pracownik(11, 32);
select wloz_paczki_pracownik(11, 33);
select wloz_paczki_pracownik(11, 34);
select wloz_paczki_pracownik(11, 35);
select wloz_paczki_pracownik(11, 36);
select wloz_paczki_pracownik(11, 37);
select wloz_paczki_pracownik(11, 38);
select wloz_paczki_pracownik(11, 39);
select wloz_paczki_pracownik(11, 40);
select wloz_paczki_pracownik(12, 1);
select wloz_paczki_pracownik(12, 2);
select wloz_paczki_pracownik(12, 3);
select wloz_paczki_pracownik(12, 4);
select wloz_paczki_pracownik(12, 5);
select wloz_paczki_pracownik(12, 6);
select wloz_paczki_pracownik(12, 7);
select wloz_paczki_pracownik(12, 8);
select wloz_paczki_pracownik(12, 9);
select wloz_paczki_pracownik(12, 10);
select wloz_paczki_pracownik(12, 11);
select wloz_paczki_pracownik(12, 12);
select wloz_paczki_pracownik(12, 13);
select wloz_paczki_pracownik(12, 14);
select wloz_paczki_pracownik(12, 15);
select wloz_paczki_pracownik(12, 16);
select wloz_paczki_pracownik(12, 17);
select wloz_paczki_pracownik(12, 18);
select wloz_paczki_pracownik(12, 19);
select wloz_paczki_pracownik(12, 20);
select wloz_paczki_pracownik(12, 21);
select wloz_paczki_pracownik(12, 22);
select wloz_paczki_pracownik(12, 23);
select wloz_paczki_pracownik(12, 24);
select wloz_paczki_pracownik(12, 25);
select wloz_paczki_pracownik(12, 26);
select wloz_paczki_pracownik(12, 27);
select wloz_paczki_pracownik(12, 28);
select wloz_paczki_pracownik(12, 29);
select wloz_paczki_pracownik(12, 30);
select wloz_paczki_pracownik(12, 31);
select wloz_paczki_pracownik(12, 32);
select wloz_paczki_pracownik(12, 33);
select wloz_paczki_pracownik(12, 34);
select wloz_paczki_pracownik(12, 35);
select wloz_paczki_pracownik(12, 36);
select wloz_paczki_pracownik(12, 37);
select wloz_paczki_pracownik(12, 38);
select wloz_paczki_pracownik(12, 39);
select wloz_paczki_pracownik(12, 40);
select wloz_paczki_pracownik(13, 1);
select wloz_paczki_pracownik(13, 2);
select wloz_paczki_pracownik(13, 3);
select wloz_paczki_pracownik(13, 4);
select wloz_paczki_pracownik(13, 5);
select wloz_paczki_pracownik(13, 6);
select wloz_paczki_pracownik(13, 7);
select wloz_paczki_pracownik(13, 8);
select wloz_paczki_pracownik(13, 9);
select wloz_paczki_pracownik(13, 10);
select wloz_paczki_pracownik(13, 11);
select wloz_paczki_pracownik(13, 12);
select wloz_paczki_pracownik(13, 13);
select wloz_paczki_pracownik(13, 14);
select wloz_paczki_pracownik(13, 15);
select wloz_paczki_pracownik(13, 16);
select wloz_paczki_pracownik(13, 17);
select wloz_paczki_pracownik(13, 18);
select wloz_paczki_pracownik(13, 19);
select wloz_paczki_pracownik(13, 20);
select wloz_paczki_pracownik(13, 21);
select wloz_paczki_pracownik(13, 22);
select wloz_paczki_pracownik(13, 23);
select wloz_paczki_pracownik(13, 24);
select wloz_paczki_pracownik(13, 25);
select wloz_paczki_pracownik(13, 26);
select wloz_paczki_pracownik(13, 27);
select wloz_paczki_pracownik(13, 28);
select wloz_paczki_pracownik(13, 29);
select wloz_paczki_pracownik(13, 30);
select wloz_paczki_pracownik(13, 31);
select wloz_paczki_pracownik(13, 32);
select wloz_paczki_pracownik(13, 33);
select wloz_paczki_pracownik(13, 34);
select wloz_paczki_pracownik(13, 35);
select wloz_paczki_pracownik(13, 36);
select wloz_paczki_pracownik(13, 37);
select wloz_paczki_pracownik(13, 38);
select wloz_paczki_pracownik(13, 39);
select wloz_paczki_pracownik(13, 40);
select wloz_paczki_pracownik(14, 1);
select wloz_paczki_pracownik(14, 2);
select wloz_paczki_pracownik(14, 3);
select wloz_paczki_pracownik(14, 4);
select wloz_paczki_pracownik(14, 5);
select wloz_paczki_pracownik(14, 6);
select wloz_paczki_pracownik(14, 7);
select wloz_paczki_pracownik(14, 8);
select wloz_paczki_pracownik(14, 9);
select wloz_paczki_pracownik(14, 10);
select wloz_paczki_pracownik(14, 11);
select wloz_paczki_pracownik(14, 12);
select wloz_paczki_pracownik(14, 13);
select wloz_paczki_pracownik(14, 14);
select wloz_paczki_pracownik(14, 15);
select wloz_paczki_pracownik(14, 16);
select wloz_paczki_pracownik(14, 17);
select wloz_paczki_pracownik(14, 18);
select wloz_paczki_pracownik(14, 19);
select wloz_paczki_pracownik(14, 20);
select wloz_paczki_pracownik(14, 21);
select wloz_paczki_pracownik(14, 22);
select wloz_paczki_pracownik(14, 23);
select wloz_paczki_pracownik(14, 24);
select wloz_paczki_pracownik(14, 25);
select wloz_paczki_pracownik(14, 26);
select wloz_paczki_pracownik(14, 27);
select wloz_paczki_pracownik(14, 28);
select wloz_paczki_pracownik(14, 29);
select wloz_paczki_pracownik(14, 30);
select wloz_paczki_pracownik(14, 31);
select wloz_paczki_pracownik(14, 32);
select wloz_paczki_pracownik(14, 33);
select wloz_paczki_pracownik(14, 34);
select wloz_paczki_pracownik(14, 35);
select wloz_paczki_pracownik(14, 36);
select wloz_paczki_pracownik(14, 37);
select wloz_paczki_pracownik(14, 38);
select wloz_paczki_pracownik(14, 39);
select wloz_paczki_pracownik(14, 40);
select wloz_paczki_pracownik(15, 1);
select wloz_paczki_pracownik(15, 2);
select wloz_paczki_pracownik(15, 3);
select wloz_paczki_pracownik(15, 4);
select wloz_paczki_pracownik(15, 5);
select wloz_paczki_pracownik(15, 6);
select wloz_paczki_pracownik(15, 7);
select wloz_paczki_pracownik(15, 8);
select wloz_paczki_pracownik(15, 9);
select wloz_paczki_pracownik(15, 10);
select wloz_paczki_pracownik(15, 11);
select wloz_paczki_pracownik(15, 12);
select wloz_paczki_pracownik(15, 13);
select wloz_paczki_pracownik(15, 14);
select wloz_paczki_pracownik(15, 15);
select wloz_paczki_pracownik(15, 16);
select wloz_paczki_pracownik(15, 17);
select wloz_paczki_pracownik(15, 18);
select wloz_paczki_pracownik(15, 19);
select wloz_paczki_pracownik(15, 20);
select wloz_paczki_pracownik(15, 21);
select wloz_paczki_pracownik(15, 22);
select wloz_paczki_pracownik(15, 23);
select wloz_paczki_pracownik(15, 24);
select wloz_paczki_pracownik(15, 25);
select wloz_paczki_pracownik(15, 26);
select wloz_paczki_pracownik(15, 27);
select wloz_paczki_pracownik(15, 28);
select wloz_paczki_pracownik(15, 29);
select wloz_paczki_pracownik(15, 30);
select wloz_paczki_pracownik(15, 31);
select wloz_paczki_pracownik(15, 32);
select wloz_paczki_pracownik(15, 33);
select wloz_paczki_pracownik(15, 34);
select wloz_paczki_pracownik(15, 35);
select wloz_paczki_pracownik(15, 36);
select wloz_paczki_pracownik(15, 37);
select wloz_paczki_pracownik(15, 38);
select wloz_paczki_pracownik(15, 39);
select wloz_paczki_pracownik(15, 40);
select wloz_paczki_pracownik(16, 1);
select wloz_paczki_pracownik(16, 2);
select wloz_paczki_pracownik(16, 3);
select wloz_paczki_pracownik(16, 4);
select wloz_paczki_pracownik(16, 5);
select wloz_paczki_pracownik(16, 6);
select wloz_paczki_pracownik(16, 7);
select wloz_paczki_pracownik(16, 8);
select wloz_paczki_pracownik(16, 9);
select wloz_paczki_pracownik(16, 10);
select wloz_paczki_pracownik(16, 11);
select wloz_paczki_pracownik(16, 12);
select wloz_paczki_pracownik(16, 13);
select wloz_paczki_pracownik(16, 14);
select wloz_paczki_pracownik(16, 15);
select wloz_paczki_pracownik(16, 16);
select wloz_paczki_pracownik(16, 17);
select wloz_paczki_pracownik(16, 18);
select wloz_paczki_pracownik(16, 19);
select wloz_paczki_pracownik(16, 20);
select wloz_paczki_pracownik(16, 21);
select wloz_paczki_pracownik(16, 22);
select wloz_paczki_pracownik(16, 23);
select wloz_paczki_pracownik(16, 24);
select wloz_paczki_pracownik(16, 25);
select wloz_paczki_pracownik(16, 26);
select wloz_paczki_pracownik(16, 27);
select wloz_paczki_pracownik(16, 28);
select wloz_paczki_pracownik(16, 29);
select wloz_paczki_pracownik(16, 30);
select wloz_paczki_pracownik(16, 31);
select wloz_paczki_pracownik(16, 32);
select wloz_paczki_pracownik(16, 33);
select wloz_paczki_pracownik(16, 34);
select wloz_paczki_pracownik(16, 35);
select wloz_paczki_pracownik(16, 36);
select wloz_paczki_pracownik(16, 37);
select wloz_paczki_pracownik(16, 38);
select wloz_paczki_pracownik(16, 39);
select wloz_paczki_pracownik(16, 40);
select wloz_paczki_pracownik(17, 1);
select wloz_paczki_pracownik(17, 2);
select wloz_paczki_pracownik(17, 3);
select wloz_paczki_pracownik(17, 4);
select wloz_paczki_pracownik(17, 5);
select wloz_paczki_pracownik(17, 6);
select wloz_paczki_pracownik(17, 7);
select wloz_paczki_pracownik(17, 8);
select wloz_paczki_pracownik(17, 9);
select wloz_paczki_pracownik(17, 10);
select wloz_paczki_pracownik(17, 11);
select wloz_paczki_pracownik(17, 12);
select wloz_paczki_pracownik(17, 13);
select wloz_paczki_pracownik(17, 14);
select wloz_paczki_pracownik(17, 15);
select wloz_paczki_pracownik(17, 16);
select wloz_paczki_pracownik(17, 17);
select wloz_paczki_pracownik(17, 18);
select wloz_paczki_pracownik(17, 19);
select wloz_paczki_pracownik(17, 20);
select wloz_paczki_pracownik(17, 21);
select wloz_paczki_pracownik(17, 22);
select wloz_paczki_pracownik(17, 23);
select wloz_paczki_pracownik(17, 24);
select wloz_paczki_pracownik(17, 25);
select wloz_paczki_pracownik(17, 26);
select wloz_paczki_pracownik(17, 27);
select wloz_paczki_pracownik(17, 28);
select wloz_paczki_pracownik(17, 29);
select wloz_paczki_pracownik(17, 30);
select wloz_paczki_pracownik(17, 31);
select wloz_paczki_pracownik(17, 32);
select wloz_paczki_pracownik(17, 33);
select wloz_paczki_pracownik(17, 34);
select wloz_paczki_pracownik(17, 35);
select wloz_paczki_pracownik(17, 36);
select wloz_paczki_pracownik(17, 37);
select wloz_paczki_pracownik(17, 38);
select wloz_paczki_pracownik(17, 39);
select wloz_paczki_pracownik(17, 40);
select wloz_paczki_pracownik(18, 1);
select wloz_paczki_pracownik(18, 2);
select wloz_paczki_pracownik(18, 3);
select wloz_paczki_pracownik(18, 4);
select wloz_paczki_pracownik(18, 5);
select wloz_paczki_pracownik(18, 6);
select wloz_paczki_pracownik(18, 7);
select wloz_paczki_pracownik(18, 8);
select wloz_paczki_pracownik(18, 9);
select wloz_paczki_pracownik(18, 10);
select wloz_paczki_pracownik(18, 11);
select wloz_paczki_pracownik(18, 12);
select wloz_paczki_pracownik(18, 13);
select wloz_paczki_pracownik(18, 14);
select wloz_paczki_pracownik(18, 15);
select wloz_paczki_pracownik(18, 16);
select wloz_paczki_pracownik(18, 17);
select wloz_paczki_pracownik(18, 18);
select wloz_paczki_pracownik(18, 19);
select wloz_paczki_pracownik(18, 20);
select wloz_paczki_pracownik(18, 21);
select wloz_paczki_pracownik(18, 22);
select wloz_paczki_pracownik(18, 23);
select wloz_paczki_pracownik(18, 24);
select wloz_paczki_pracownik(18, 25);
select wloz_paczki_pracownik(18, 26);
select wloz_paczki_pracownik(18, 27);
select wloz_paczki_pracownik(18, 28);
select wloz_paczki_pracownik(18, 29);
select wloz_paczki_pracownik(18, 30);
select wloz_paczki_pracownik(18, 31);
select wloz_paczki_pracownik(18, 32);
select wloz_paczki_pracownik(18, 33);
select wloz_paczki_pracownik(18, 34);
select wloz_paczki_pracownik(18, 35);
select wloz_paczki_pracownik(18, 36);
select wloz_paczki_pracownik(18, 37);
select wloz_paczki_pracownik(18, 38);
select wloz_paczki_pracownik(18, 39);
select wloz_paczki_pracownik(18, 40);
select wloz_paczki_pracownik(19, 1);
select wloz_paczki_pracownik(19, 2);
select wloz_paczki_pracownik(19, 3);
select wloz_paczki_pracownik(19, 4);
select wloz_paczki_pracownik(19, 5);
select wloz_paczki_pracownik(19, 6);
select wloz_paczki_pracownik(19, 7);
select wloz_paczki_pracownik(19, 8);
select wloz_paczki_pracownik(19, 9);
select wloz_paczki_pracownik(19, 10);
select wloz_paczki_pracownik(19, 11);
select wloz_paczki_pracownik(19, 12);
select wloz_paczki_pracownik(19, 13);
select wloz_paczki_pracownik(19, 14);
select wloz_paczki_pracownik(19, 15);
select wloz_paczki_pracownik(19, 16);
select wloz_paczki_pracownik(19, 17);
select wloz_paczki_pracownik(19, 18);
select wloz_paczki_pracownik(19, 19);
select wloz_paczki_pracownik(19, 20);
select wloz_paczki_pracownik(19, 21);
select wloz_paczki_pracownik(19, 22);
select wloz_paczki_pracownik(19, 23);
select wloz_paczki_pracownik(19, 24);
select wloz_paczki_pracownik(19, 25);
select wloz_paczki_pracownik(19, 26);
select wloz_paczki_pracownik(19, 27);
select wloz_paczki_pracownik(19, 28);
select wloz_paczki_pracownik(19, 29);
select wloz_paczki_pracownik(19, 30);
select wloz_paczki_pracownik(19, 31);
select wloz_paczki_pracownik(19, 32);
select wloz_paczki_pracownik(19, 33);
select wloz_paczki_pracownik(19, 34);
select wloz_paczki_pracownik(19, 35);
select wloz_paczki_pracownik(19, 36);
select wloz_paczki_pracownik(19, 37);
select wloz_paczki_pracownik(19, 38);
select wloz_paczki_pracownik(19, 39);
select wloz_paczki_pracownik(19, 40);
select wloz_paczki_pracownik(20, 1);
select wloz_paczki_pracownik(20, 2);
select wloz_paczki_pracownik(20, 3);
select wloz_paczki_pracownik(20, 4);
select wloz_paczki_pracownik(20, 5);
select wloz_paczki_pracownik(20, 6);
select wloz_paczki_pracownik(20, 7);
select wloz_paczki_pracownik(20, 8);
select wloz_paczki_pracownik(20, 9);
select wloz_paczki_pracownik(20, 10);
select wloz_paczki_pracownik(20, 11);
select wloz_paczki_pracownik(20, 12);
select wloz_paczki_pracownik(20, 13);
select wloz_paczki_pracownik(20, 14);
select wloz_paczki_pracownik(20, 15);
select wloz_paczki_pracownik(20, 16);
select wloz_paczki_pracownik(20, 17);
select wloz_paczki_pracownik(20, 18);
select wloz_paczki_pracownik(20, 19);
select wloz_paczki_pracownik(20, 20);
select wloz_paczki_pracownik(20, 21);
select wloz_paczki_pracownik(20, 22);
select wloz_paczki_pracownik(20, 23);
select wloz_paczki_pracownik(20, 24);
select wloz_paczki_pracownik(20, 25);
select wloz_paczki_pracownik(20, 26);
select wloz_paczki_pracownik(20, 27);
select wloz_paczki_pracownik(20, 28);
select wloz_paczki_pracownik(20, 29);
select wloz_paczki_pracownik(20, 30);
select wloz_paczki_pracownik(20, 31);
select wloz_paczki_pracownik(20, 32);
select wloz_paczki_pracownik(20, 33);
select wloz_paczki_pracownik(20, 34);
select wloz_paczki_pracownik(20, 35);
select wloz_paczki_pracownik(20, 36);
select wloz_paczki_pracownik(20, 37);
select wloz_paczki_pracownik(20, 38);
select wloz_paczki_pracownik(20, 39);
select wloz_paczki_pracownik(20, 40);
select wloz_paczki_pracownik(21, 1);
select wloz_paczki_pracownik(21, 2);
select wloz_paczki_pracownik(21, 3);
select wloz_paczki_pracownik(21, 4);
select wloz_paczki_pracownik(21, 5);
select wloz_paczki_pracownik(21, 6);
select wloz_paczki_pracownik(21, 7);
select wloz_paczki_pracownik(21, 8);
select wloz_paczki_pracownik(21, 9);
select wloz_paczki_pracownik(21, 10);
select wloz_paczki_pracownik(21, 11);
select wloz_paczki_pracownik(21, 12);
select wloz_paczki_pracownik(21, 13);
select wloz_paczki_pracownik(21, 14);
select wloz_paczki_pracownik(21, 15);
select wloz_paczki_pracownik(21, 16);
select wloz_paczki_pracownik(21, 17);
select wloz_paczki_pracownik(21, 18);
select wloz_paczki_pracownik(21, 19);
select wloz_paczki_pracownik(21, 20);
select wloz_paczki_pracownik(21, 21);
select wloz_paczki_pracownik(21, 22);
select wloz_paczki_pracownik(21, 23);
select wloz_paczki_pracownik(21, 24);
select wloz_paczki_pracownik(21, 25);
select wloz_paczki_pracownik(21, 26);
select wloz_paczki_pracownik(21, 27);
select wloz_paczki_pracownik(21, 28);
select wloz_paczki_pracownik(21, 29);
select wloz_paczki_pracownik(21, 30);
select wloz_paczki_pracownik(21, 31);
select wloz_paczki_pracownik(21, 32);
select wloz_paczki_pracownik(21, 33);
select wloz_paczki_pracownik(21, 34);
select wloz_paczki_pracownik(21, 35);
select wloz_paczki_pracownik(21, 36);
select wloz_paczki_pracownik(21, 37);
select wloz_paczki_pracownik(21, 38);
select wloz_paczki_pracownik(21, 39);
select wloz_paczki_pracownik(21, 40);
select wloz_paczki_pracownik(22, 1);
select wloz_paczki_pracownik(22, 2);
select wloz_paczki_pracownik(22, 3);
select wloz_paczki_pracownik(22, 4);
select wloz_paczki_pracownik(22, 5);
select wloz_paczki_pracownik(22, 6);
select wloz_paczki_pracownik(22, 7);
select wloz_paczki_pracownik(22, 8);
select wloz_paczki_pracownik(22, 9);
select wloz_paczki_pracownik(22, 10);
select wloz_paczki_pracownik(22, 11);
select wloz_paczki_pracownik(22, 12);
select wloz_paczki_pracownik(22, 13);
select wloz_paczki_pracownik(22, 14);
select wloz_paczki_pracownik(22, 15);
select wloz_paczki_pracownik(22, 16);
select wloz_paczki_pracownik(22, 17);
select wloz_paczki_pracownik(22, 18);
select wloz_paczki_pracownik(22, 19);
select wloz_paczki_pracownik(22, 20);
select wloz_paczki_pracownik(22, 21);
select wloz_paczki_pracownik(22, 22);
select wloz_paczki_pracownik(22, 23);
select wloz_paczki_pracownik(22, 24);
select wloz_paczki_pracownik(22, 25);
select wloz_paczki_pracownik(22, 26);
select wloz_paczki_pracownik(22, 27);
select wloz_paczki_pracownik(22, 28);
select wloz_paczki_pracownik(22, 29);
select wloz_paczki_pracownik(22, 30);
select wloz_paczki_pracownik(22, 31);
select wloz_paczki_pracownik(22, 32);
select wloz_paczki_pracownik(22, 33);
select wloz_paczki_pracownik(22, 34);
select wloz_paczki_pracownik(22, 35);
select wloz_paczki_pracownik(22, 36);
select wloz_paczki_pracownik(22, 37);
select wloz_paczki_pracownik(22, 38);
select wloz_paczki_pracownik(22, 39);
select wloz_paczki_pracownik(22, 40);
select wloz_paczki_pracownik(23, 1);
select wloz_paczki_pracownik(23, 2);
select wloz_paczki_pracownik(23, 3);
select wloz_paczki_pracownik(23, 4);
select wloz_paczki_pracownik(23, 5);
select wloz_paczki_pracownik(23, 6);
select wloz_paczki_pracownik(23, 7);
select wloz_paczki_pracownik(23, 8);
select wloz_paczki_pracownik(23, 9);
select wloz_paczki_pracownik(23, 10);
select wloz_paczki_pracownik(23, 11);
select wloz_paczki_pracownik(23, 12);
select wloz_paczki_pracownik(23, 13);
select wloz_paczki_pracownik(23, 14);
select wloz_paczki_pracownik(23, 15);
select wloz_paczki_pracownik(23, 16);
select wloz_paczki_pracownik(23, 17);
select wloz_paczki_pracownik(23, 18);
select wloz_paczki_pracownik(23, 19);
select wloz_paczki_pracownik(23, 20);
select wloz_paczki_pracownik(23, 21);
select wloz_paczki_pracownik(23, 22);
select wloz_paczki_pracownik(23, 23);
select wloz_paczki_pracownik(23, 24);
select wloz_paczki_pracownik(23, 25);
select wloz_paczki_pracownik(23, 26);
select wloz_paczki_pracownik(23, 27);
select wloz_paczki_pracownik(23, 28);
select wloz_paczki_pracownik(23, 29);
select wloz_paczki_pracownik(23, 30);
select wloz_paczki_pracownik(23, 31);
select wloz_paczki_pracownik(23, 32);
select wloz_paczki_pracownik(23, 33);
select wloz_paczki_pracownik(23, 34);
select wloz_paczki_pracownik(23, 35);
select wloz_paczki_pracownik(23, 36);
select wloz_paczki_pracownik(23, 37);
select wloz_paczki_pracownik(23, 38);
select wloz_paczki_pracownik(23, 39);
select wloz_paczki_pracownik(23, 40);
select wloz_paczki_pracownik(24, 1);
select wloz_paczki_pracownik(24, 2);
select wloz_paczki_pracownik(24, 3);
select wloz_paczki_pracownik(24, 4);
select wloz_paczki_pracownik(24, 5);
select wloz_paczki_pracownik(24, 6);
select wloz_paczki_pracownik(24, 7);
select wloz_paczki_pracownik(24, 8);
select wloz_paczki_pracownik(24, 9);
select wloz_paczki_pracownik(24, 10);
select wloz_paczki_pracownik(24, 11);
select wloz_paczki_pracownik(24, 12);
select wloz_paczki_pracownik(24, 13);
select wloz_paczki_pracownik(24, 14);
select wloz_paczki_pracownik(24, 15);
select wloz_paczki_pracownik(24, 16);
select wloz_paczki_pracownik(24, 17);
select wloz_paczki_pracownik(24, 18);
select wloz_paczki_pracownik(24, 19);
select wloz_paczki_pracownik(24, 20);
select wloz_paczki_pracownik(24, 21);
select wloz_paczki_pracownik(24, 22);
select wloz_paczki_pracownik(24, 23);
select wloz_paczki_pracownik(24, 24);
select wloz_paczki_pracownik(24, 25);
select wloz_paczki_pracownik(24, 26);
select wloz_paczki_pracownik(24, 27);
select wloz_paczki_pracownik(24, 28);
select wloz_paczki_pracownik(24, 29);
select wloz_paczki_pracownik(24, 30);
select wloz_paczki_pracownik(24, 31);
select wloz_paczki_pracownik(24, 32);
select wloz_paczki_pracownik(24, 33);
select wloz_paczki_pracownik(24, 34);
select wloz_paczki_pracownik(24, 35);
select wloz_paczki_pracownik(24, 36);
select wloz_paczki_pracownik(24, 37);
select wloz_paczki_pracownik(24, 38);
select wloz_paczki_pracownik(24, 39);
select wloz_paczki_pracownik(24, 40);
select wloz_paczki_pracownik(25, 1);
select wloz_paczki_pracownik(25, 2);
select wloz_paczki_pracownik(25, 3);
select wloz_paczki_pracownik(25, 4);
select wloz_paczki_pracownik(25, 5);
select wloz_paczki_pracownik(25, 6);
select wloz_paczki_pracownik(25, 7);
select wloz_paczki_pracownik(25, 8);
select wloz_paczki_pracownik(25, 9);
select wloz_paczki_pracownik(25, 10);
select wloz_paczki_pracownik(25, 11);
select wloz_paczki_pracownik(25, 12);
select wloz_paczki_pracownik(25, 13);
select wloz_paczki_pracownik(25, 14);
select wloz_paczki_pracownik(25, 15);
select wloz_paczki_pracownik(25, 16);
select wloz_paczki_pracownik(25, 17);
select wloz_paczki_pracownik(25, 18);
select wloz_paczki_pracownik(25, 19);
select wloz_paczki_pracownik(25, 20);
select wloz_paczki_pracownik(25, 21);
select wloz_paczki_pracownik(25, 22);
select wloz_paczki_pracownik(25, 23);
select wloz_paczki_pracownik(25, 24);
select wloz_paczki_pracownik(25, 25);
select wloz_paczki_pracownik(25, 26);
select wloz_paczki_pracownik(25, 27);
select wloz_paczki_pracownik(25, 28);
select wloz_paczki_pracownik(25, 29);
select wloz_paczki_pracownik(25, 30);
select wloz_paczki_pracownik(25, 31);
select wloz_paczki_pracownik(25, 32);
select wloz_paczki_pracownik(25, 33);
select wloz_paczki_pracownik(25, 34);
select wloz_paczki_pracownik(25, 35);
select wloz_paczki_pracownik(25, 36);
select wloz_paczki_pracownik(25, 37);
select wloz_paczki_pracownik(25, 38);
select wloz_paczki_pracownik(25, 39);
select wloz_paczki_pracownik(25, 40);


select zakoncz_przewoz(10);
select zakoncz_przewoz(11);
select zakoncz_przewoz(12);
select zakoncz_przewoz(13);
select zakoncz_przewoz(14);
select zakoncz_przewoz(15);
select zakoncz_przewoz(16);
select zakoncz_przewoz(17);
select zakoncz_przewoz(18);
select zakoncz_przewoz(19);
select zakoncz_przewoz(20);
select zakoncz_przewoz(21);
select zakoncz_przewoz(22);
select zakoncz_przewoz(23);
select zakoncz_przewoz(24);
select zakoncz_przewoz(25)




