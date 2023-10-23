


update files
        set dams_uan = 'SG-' || file_name
        where dams_uan is null and folder_id in (select folder_id from folders WHERE project_id= 129);


update files
  set preview_image = ('https://ids.si.edu/ids/deliveryService?id=' || dams_uan)
  where dams_uan is not null AND preview_image IS NULL and folder_id in (select folder_id from folders WHERE project_id= 129);


insert into files_links  (
    file_id,
    link_name,
    link_url
    )
    (
    select
      f.file_id,
      'IIIF Manifest',
      'https://ids.si.edu/ids/manifest/' || f.dams_uan
    from files f
    where
      f.dams_uan is not null
      AND f.file_id NOT IN (
          SELECT file_id
          FROM files_links
          WHERE link_name = 'IIIF Manifest'
        )
        and folder_id in (select folder_id from folders WHERE project_id= 129)
    );


insert into files_links  (
        file_id,
        link_name,
        link_url
        )
        (
        select
            file_id,
            '<img src="/static/logo-iiif.png">',
            'https://iiif.si.edu/mirador/?manifest=https://ids.si.edu/ids/manifest/' || dams_uan
        from files f
        where
            f.dams_uan is not null
            AND f.file_id NOT IN (
                SELECT file_id
                FROM files_links
                WHERE link_name = '<img src="/static/logo-iiif.png">'
              )
                and folder_id in (select folder_id from folders WHERE project_id= 129)
          );

--collectionsearch
insert into files_links  (
        file_id,
        link_name,
        link_url
        )
        (
        select
            file_id,
            'Collections Search',
            'https://collections.si.edu/search/results.htm?q=%22' || dams_uan || '%22'
        from files f
        where
            f.dams_uan is not null
            AND f.file_id NOT IN (
                SELECT file_id
                FROM files_links
                WHERE link_name = 'Collections Search'
              )
                and folder_id in (select folder_id from folders WHERE project_id= 120)
          );
