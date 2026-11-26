with TEXT_IO; use TEXT_IO;

procedure MMI is
    -- Jerry Pournelle's Floating Point Benchmark
    -- October 1982 Byte, pages 254 - 270
    -- integer version: each element of C fits in 16 bits; the sum is kept in base 10000

    A : array( 1..20, 1..20 ) of integer;
    B : array( 1..20, 1..20 ) of integer;
    C : array( 1..20, 1..20 ) of integer;

    SummHi, SummLo : integer;

    procedure Fill_A is
    begin
        for i in 1..20 loop
            for j in 1..20 loop
                A(i,j) := i + j;
            end loop;
        end loop;
    end Fill_A;

    procedure Fill_B is
    begin
        for i in 1..20 loop
            for j in 1..20 loop
                B(i,j) := ( i + j ) / j;
            end loop;
        end loop;
    end Fill_B;

    procedure Fill_C is
    begin
        for i in 1..20 loop
            for j in 1..20 loop
                C(i,j) := 0;
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
                SummLo := SummLo + C(i,j);
                while SummLo >= 10000 loop
                    SummLo := SummLo - 10000;
                    SummHi := SummHi + 1;
                end loop;
            end loop;
        end loop;
    end Summit;

begin
    SummHi := 0;
    SummLo := 0;
    Fill_A;
    Fill_B;
    Fill_C;
    Matrix_Multiply;
    Summit;
    if SummHi = 46 and SummLo = 5880 then
        put( "summ is exactly 465880" );
    else
        put( "summ is not 465880" );
    end if;
    new_line;
end MMI;
