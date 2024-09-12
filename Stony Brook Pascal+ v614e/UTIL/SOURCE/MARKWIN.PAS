PROGRAM markwin;
{$I-,V-}

uses dos;

var
    f : file;
    c : word;
    w : word;
    s : array [0..1] of char;
    n : string;
    b : set of 0..15;
    path, name, ext : string;
begin
    n := paramstr(1);
    fsplit(n, path, name, ext);
    
    if ext = '' then
	n := path + name + '.DLL';

    assign(f, n);
    reset(f, 1);
    if ioresult <> 0 then
	begin
	
	if ext = '' then
	    n := path + name + '.EXE';
	    
	assign(f, n);
	reset(f, 1);
	if ioresult <> 0 THEN
	    BEGIN
	    write('Could not open file: ', path+name);

	    if ext = '' then
		writeln('(.EXE|.DLL)')
	    else
		writeln(ext);
		
	    halt(1);
	    end;
	end;
    
    (* is it a segmented executable *)
	
    seek(f, $3c);
    blockread(f, w, 2, c);
    seek(f, w);
    blockread(f, s, 2, c);
    if s <> 'NE' then
        begin
	writeln('Not a windows executable');
        halt(1);
        end;
    
    (* mark it as protected mode compatible *)
    
    seek(f, w+$c);
    blockread(f, b, 2, c);
    b := b + [8, 9];
    seek(f, w+$c);
    blockwrite(f, b, 2, c);
    
    (* mark it as a Windows 3.1 program *)
    
    seek(f, w+$3e);
    w := $300;
    blockwrite(f, w, 2, c);
    if ioresult <> 0 then
        begin
	writeln('Error modifying file');
	halt(1);
	end;
    close(f);
end.
