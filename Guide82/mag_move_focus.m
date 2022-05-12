mag_cp = get(get(f45,'parent'),'currentpoint');

set(f41,'string',['Mouse at focus point '...
    num2str(fix(mag_cp(1,1))) ' ' num2str((mag_cp(1,2)))]);
