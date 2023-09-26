
-- jpc_massdigi_ids

-- aspace_hmo	c187689b8dbf9f97267ba64b221c3c7e	a8459388-996f-4f14-8833-43c2ea4ca09e
-- hmo_image	6e34612c-ff54-42c3-9257-2e24278503e3	JPC-00000002-a
-- image_iiif	JPC-00000002-b	https://ids.si.edu/ids/manifest/JPC-00000002_B

-- hmo_tif_prefix - HMO to Images without the suffix
	
	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (with data AS (select distinct SUBSTRING_INDEX(file_name, '_', 1) hmo from files where folder_id = 1996) SELECT 'hmo_tif_prefix', uuid_v4s(), d.hmo from data d);

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (with data AS (select distinct SUBSTRING_INDEX(file_name, '_', 1) hmo from files where folder_id = 1997) SELECT 'hmo_tif_prefix', uuid_v4s(), d.hmo from data d);

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (with data AS (select distinct SUBSTRING_INDEX(file_name, '_', 1) hmo from files where folder_id = 1998) SELECT 'hmo_tif_prefix', uuid_v4s(), d.hmo from data d);

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (with data AS (select distinct SUBSTRING_INDEX(file_name, '_', 1) hmo from files where folder_id = 1999) SELECT 'hmo_tif_prefix', uuid_v4s(), d.hmo from data d);

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (with data AS (select distinct SUBSTRING_INDEX(file_name, '_', 1) hmo from files where folder_id = 2000) SELECT 'hmo_tif_prefix', uuid_v4s(), d.hmo from data d);


-- hmo_tif

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (
	 with data AS (select id1_value, id2_value from jpc_massdigi_ids where id_relationship = 'hmo_tif_prefix') 
	 SELECT 'hmo_tif', d.id1_value, lower(replace(f.file_name, '_', '-')) from data d, files f 
		where (folder_id = 1996 or folder_id = 1997 or folder_id = 1998 or folder_id = 1999 or folder_id = 2000)
			and d.id2_value = SUBSTRING_INDEX(file_name, '_', 1)
	 );


-- refid_hmo - ASpace folder RefID to HMO

-- c187689b8dbf9f97267ba64b221c3c7e 1996
-- 0d7793d287aa7bc342b97fa8d2ac0ae8 1997
-- e5b79edeb3842a0b4921436de2ed743a 1998
-- 347901ab7b4e0b09efe4fe9a24c2f003 1999
-- bffe84f3ca1d7f8e60ca068e7a20feec 2000

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (
	 with data AS (select id1_value, id2_value from jpc_massdigi_ids where id_relationship = 'hmo_tif_prefix') 
	 SELECT 'refid_hmo', 'c187689b8dbf9f97267ba64b221c3c7e', d.id1_value from data d, files f where folder_id = 1996 and d.id2_value = SUBSTRING_INDEX(file_name, '_', 1) group by d.id1_value
	 );

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (
	 with data AS (select id1_value, id2_value from jpc_massdigi_ids where id_relationship = 'hmo_tif_prefix') 
	 SELECT 'refid_hmo', '0d7793d287aa7bc342b97fa8d2ac0ae8', d.id1_value from data d, files f where folder_id = 1997 and d.id2_value = SUBSTRING_INDEX(file_name, '_', 1) group by d.id1_value
	 );
	 
	 INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (
	 with data AS (select id1_value, id2_value from jpc_massdigi_ids where id_relationship = 'hmo_tif_prefix') 
	 SELECT 'refid_hmo', 'e5b79edeb3842a0b4921436de2ed743a', d.id1_value from data d, files f where folder_id = 1998 and d.id2_value = SUBSTRING_INDEX(file_name, '_', 1) group by d.id1_value
	 );
	 
	 INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (
	 with data AS (select id1_value, id2_value from jpc_massdigi_ids where id_relationship = 'hmo_tif_prefix') 
	 SELECT 'refid_hmo', '347901ab7b4e0b09efe4fe9a24c2f003', d.id1_value from data d, files f where folder_id = 1999 and d.id2_value = SUBSTRING_INDEX(file_name, '_', 1) group by d.id1_value
	 );
	 
	 INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (
	 with data AS (select id1_value, id2_value from jpc_massdigi_ids where id_relationship = 'hmo_tif_prefix') 
	 SELECT 'refid_hmo', 'bffe84f3ca1d7f8e60ca068e7a20feec', d.id1_value from data d, files f where folder_id = 2000 and d.id2_value = SUBSTRING_INDEX(file_name, '_', 1) group by d.id1_value
	 );
	 

-- tif_dams - Image to DAMS UAN

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (
	 with data AS (select id1_value, id2_value from jpc_massdigi_ids where id_relationship = 'hmo_tif_prefix') 
	 SELECT 'tif_dams', lower(replace(f.file_name, '_', '-')), concat('JPC-', lower(replace(f.file_name, '_', '-'))) from data d, files f 
		where (folder_id = 1996 or folder_id = 1997 or folder_id = 1998 or folder_id = 1999 or folder_id = 2000)
			and d.id2_value = SUBSTRING_INDEX(f.file_name, '_', 1)
	 );

-- tif_iiif - Image to IIIF manifest

	INSERT INTO jpc_massdigi_ids (id_relationship, id1_value, id2_value)
	 (
	 with data AS (select id1_value, id2_value from jpc_massdigi_ids where id_relationship = 'hmo_tif_prefix') 
	 SELECT 'tif_iiif', lower(replace(f.file_name, '_', '-')), concat('https://ids.si.edu/ids/manifest/JPC-', lower(replace(f.file_name, '_', '-'))) from data d, files f 
		where (folder_id = 1996 or folder_id = 1997 or folder_id = 1998 or folder_id = 1999 or folder_id = 2000)
			and d.id2_value = SUBSTRING_INDEX(f.file_name, '_', 1)
	 );
	 
	 
-- hmo_iiif - HMO to IIIF manifest
  -- pending 

-- hmo_arches - HMO to Arches Record
  -- hmo is arches, but seems ID will be UUIDv3, so pending
 


-- FOR API
WITH 
	data AS (SELECT id1_value as hmo_id, id2_value as file_name, updated_at FROM jpc_massdigi_ids where id_relationship = 'hmo_tif'),
	data2 AS (SELECT id1_value as file_name, id2_value as dams_uan FROM jpc_massdigi_ids where id_relationship = 'tif_dams'),
	data3 AS (SELECT id1_value as aspace_refid, id2_value as hmo_id FROM jpc_massdigi_ids where id_relationship = 'refid_hmo'),
	data4 AS (SELECT id1_value as file_name, id2_value as iiif_manifest FROM jpc_massdigi_ids where id_relationship = 'tif_iiif')
SELECT 
	f.uid as osprey_id, 
	fol.project_folder as massdigi_folder,
	d.hmo_id,
	d.file_name,
	d2.dams_uan,
	d3.aspace_refid,
	d4.iiif_manifest as tif_iiif_manifest,
	null as hmo_iiif_manifest,
	null as hmo_arches,
	date_format(d.updated_at, '%Y-%m-%d %H:%i:%S') as updated_at
FROM 
	files f,
	folders fol,
	data d,
	data2 d2,
	data3 d3,
	data4 d4
where 
	(f.folder_id = 1996 or f.folder_id = 1997 or f.folder_id = 1998 or f.folder_id = 1999 or f.folder_id = 2000) and 
	f.folder_id = fol.folder_id and 
	lower(replace(f.file_name, '_', '-')) = d.file_name and 
	lower(replace(f.file_name, '_', '-')) = d2.file_name and 
	lower(replace(f.file_name, '_', '-')) = d4.file_name and 
	d.hmo_id = d3.hmo_id
ORDER BY d.updated_at DESC;
	
--Single line:
WITH data AS (SELECT id1_value as hmo_id, id2_value as file_name, updated_at FROM jpc_massdigi_ids where id_relationship = 'hmo_tif'), data2 AS (SELECT id1_value as file_name, id2_value as dams_uan FROM jpc_massdigi_ids where id_relationship = 'tif_dams'), data3 AS (SELECT id1_value as aspace_refid, id2_value as hmo_id FROM jpc_massdigi_ids where id_relationship = 'refid_hmo'), data4 AS (SELECT id1_value as file_name, id2_value as iiif_manifest FROM jpc_massdigi_ids where id_relationship = 'tif_iiif') SELECT f.uid as osprey_id, fol.project_folder as massdigi_folder, d.hmo_id, d.file_name, d2.dams_uan, d3.aspace_refid, d4.iiif_manifest as tif_iiif_manifest, null as hmo_iiif_manifest, null as hmo_arches, date_format(d.updated_at, '%Y-%m-%d %H:%i:%S') as updated_at FROM files f, folders fol, data d, data2 d2, data3 d3, data4 d4 where (f.folder_id = 1996 or f.folder_id = 1997 or f.folder_id = 1998 or f.folder_id = 1999 or f.folder_id = 2000) and f.folder_id = fol.folder_id and lower(replace(f.file_name, '_', '-')) = d.file_name and lower(replace(f.file_name, '_', '-')) = d2.file_name and lower(replace(f.file_name, '_', '-')) = d4.file_name and d.hmo_id = d3.hmo_id ORDER BY d.updated_at DESC

