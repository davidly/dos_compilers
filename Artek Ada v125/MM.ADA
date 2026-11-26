with TEXT_IO; use TEXT_IO;

procedure MM is
    -- Jerry Pournelle's Floating Point Benchmark
    -- October 1982 Byte, pages 254 - 270
    -- A and B hold small whole numbers, so the sum is exactly 465880.
    -- The program checks the sum itself rather than formatting a float.

    A : array( 1..20, 1..20 ) of float;
    B : array( 1..20, 1..20 ) of float;
    C : array( 1..20, 1..20 ) of float;

    Summ : float;

    procedure Fill_A is
    begin
        for i in 1..20 loop
            for j in 1..20 loop
                A(i,j) := float( i + j );
            end loop;
        end loop;
    end Fill_A;

    procedure Fill_B is
    begin
        for i in 1..20 loop
            for j in 1..20 loop
                B(i,j) := float( ( i + j ) / j );
            end loop;
        end loop;
    end Fill_B;

    procedure Fill_C is
    begin
        for i in 1..20 loop
            for j in 1..20 loop
                C(i,j) := 0.0;
            end loop;
        end loop;
    end Fill_C;

    procedure Matrix_Multiply is
    begin
        for i in 1..20 loop
            for j in 1..20 loop
                for k in 1..20 loop
                    C(i,j) := C(i,j) + A(i,k) * B(k,j);
                end loop;
            end loop;
        end loop;
    end Matrix_Multiply;

    procedure Summit is
    begin
        for i in 1..20 loop
            for j in 1..20 loop
                Summ := Summ + C(i,j);
            end loop;
        end loop;
    end Summit;

begin
    Summ := 0.0;
    Fill_A;
    Fill_B;
    Fill_C;
    Matrix_Multiply;
    Summit;
    if Summ = 465880.0 then
        put( "summ is exactly 465880" );
    else
        put( "summ is not 465880" );
    end if;
    new_line;
end MM;
