--
-- MAIL.ADA
--
-- An extremely simple mailing list program for Artek Ada
--
-- Copyright (C) 1986, 1987 Artek Corporation
--
-- The MAIL program is intended to demonstrate the use of
-- the CON_IO and DIRECT_IO packages.  It allows the user
-- to enter names in a screen "form", modify the information,
-- and to view the entered data.
--
-- The operation of the program should be self-explanatory.
--

with IO_EXCEPTIONS, CON_IO, DIRECT_IO, QGET;

procedure MAIL is

   -- The following data type is used to describe customer data.

   type CUSTOMER_REC is
      record
         NAME : STRING (1..32);
         ADDR1 : STRING (1..30);
         ADDR2 : STRING (1..30);
         ADDR3 : STRING (1..20);
      end record;

   -- We're going to use random-access I/O for our customer file,
   -- so DIRECT_IO is instantiated.

   package CUST_IO is new DIRECT_IO (CUSTOMER_REC);

   -- To avoid dot notation (e.g. CON_IO.SOMETHING),
   -- we USE the most important packages.

   use CUST_IO, CON_IO;

   CUSTFILE : FILE_TYPE;
   CHOICE : CHARACTER := 'E'; -- Let the default choice be "Exit"
   ANYKEY : CHARACTER; -- Used when waiting for the user to press a key

   -- The following procedure demonstrates CON_IO.  It uses a lot
   -- of routines from that package to set up a nice "look".

   procedure SET_UP_SCREEN is

      -- Set up a string of 80 spaces
      SPACES : constant STRING := (1..80 => ' ');

   begin
      BACKGROUND (4);
      CLS;
      CURSOR (0, 0);
      INTENSITY;
      COLOR (2);
      PUT ("Artek Ada Mailing List Application");
      CURSOR (0, 1);
      ALL_OFF;
      BACKGROUND (6);
      PUT (SPACES);
      ALL_OFF;
      CURSOR (0, 23);
      REV_VIDEO;
      BACKGROUND (6);
      PUT (SPACES);
      CURSOR (14, 23);
      PUT ("This application was coded entirely in Artek Ada.");
      ALL_OFF;
      CURSOR (0, 0);
   end SET_UP_SCREEN;

   -- The following procedure allows the user to enter data about new
   -- customers.

   procedure ADD_CUSTOMER is
      C : CUSTOMER_REC;
      LAST : INTEGER;

      -- Aggregates are put to good use in order to initialize the
      -- customer data to all spaces.

      procedure CLEAR_CUSTOMER (C : out CUSTOMER_REC) is
      begin
         C := (
            NAME => (others => ' '),
            ADDR1 => (others => ' '),
            ADDR2 => (others => ' '),
            ADDR3 => (others => ' ')
            );
      end CLEAR_CUSTOMER;

   begin
      SET_UP_SCREEN;
      CLEAR_CUSTOMER (C);
      BACKGROUND (4);
      BOX (0, 3, 79, 21);
      COLOR (3);
      CURSOR (60, 0);
      PUT ("Add customer");
      CURSOR (20, 8);
      PUT ("Enter name      => ");
      GET (C . NAME);
      CURSOR (20, 10);
      PUT ("Enter address 1 => ");
      GET (C . ADDR1);
      CURSOR (20, 12);
      PUT ("Enter address 2 => ");
      GET (C . ADDR2);
      CURSOR (20, 14);
      PUT ("Enter address 3 => ");
      GET (C . ADDR3);
      -- The following statement writes the customer data to the customer
      -- file.  The TO parameter specifies that we want to write the new
      -- record at the end of the file.
      WRITE (CUSTFILE, C, TO => SIZE (CUSTFILE) + 1);
   END;

   -- The following procedure allows modification of customer data.
   -- Customers are referenced through record numbers.

   procedure MODIFY_CUSTOMER is
      RECNUM : STRING (1..5) := "0    "; -- Default record number is zero
      REC : COUNT;
      C : CUSTOMER_REC;

   begin
      MAIN_LOOP:
      loop
         begin
            SET_UP_SCREEN;
            CURSOR (60, 0);
            BACKGROUND (4);
            COLOR (3);
            PUT ("Modify customer");
            -- What follows is a standard Ada technique for entering
            -- and validating data.  A block is declared within
            -- an endless loop.  The loop is only exited when legal
            -- data has been entered.  Otherwise, an exception is
            -- raised, and control passes to the end of the block,
            -- resulting in the entry starting all over again.
            loop
               CURSOR (20, 6);
               PUT ("Enter number (0=exit) => ");
               GET (RECNUM);
               begin
                  -- The VALUE attribute will raise an exception if illegal
                  -- data is contained in RECNUM.
                  REC := COUNT'VALUE (RECNUM);
                  exit;
               exception
                  when others =>
                     null;
               end;
            end loop;
            exit MAIN_LOOP when REC = 0;
            -- We read the record specified by the user.  The exception
            -- END_ERROR is raised if we read past the end of the file.
            READ (CUSTFILE, C, FROM => REC);
            CURSOR (20, 8);
            PUT ("Enter name      => ");
            GET (C . NAME);
            CURSOR (20, 10);
            PUT ("Enter address 1 => ");
            GET (C . ADDR1);
            CURSOR (20, 12);
            PUT ("Enter address 2 => ");
            GET (C . ADDR2);
            CURSOR (20, 14);
            PUT ("Enter address 3 => ");
            GET (C . ADDR3);
            -- The record is written in the same slot as it was read from.
            WRITE (CUSTFILE, C, TO => REC);
         exception
            when END_ERROR | USE_ERROR =>
               CURSOR (20, 20);
               BLINK;
               PUT ("Illegal record number.  Press any key ...");
               ALL_OFF;
               QGET (ANYKEY);
         end;
      end loop MAIN_LOOP;
   end;

   -- The VIEW procedure allows the user to "page" through the customer
   -- list on the screen.

   procedure VIEW is

      C : CUSTOMER_REC;

   begin
      SET_UP_SCREEN;
      BACKGROUND (4);
      BOX (0, 3, 79, 21);
      COLOR (3);
      CURSOR (60, 0);
      PUT ("View customers");
      -- The following line closes the customer file and opens it again
      -- as an input file.  The file is ready for input at the first record.
      RESET (CUSTFILE, MODE => IN_FILE);
      MAIN_LOOP:
      while not END_OF_FILE (CUSTFILE) loop
         CURSOR (20, 8);
         BACKGROUND (4);
         COLOR (3);
         -- The following line displays the current record number.
         -- The IMAGE attribute is necessary because we don't have
         -- a PUT for integers.
         PUT ("Record number" & COUNT'IMAGE (INDEX (CUSTFILE)));
         READ (CUSTFILE, C);
         CURSOR (20, 10);
         PUT (C . NAME);
         CURSOR (20, 12);
         PUT (C . ADDR1);
         CURSOR (20, 14);
         PUT (C . ADDR2);
         CURSOR (20, 16);
         PUT (C . ADDR3);
         CURSOR (20, 18);
         INTENSITY;
         PUT ("Press SPACE to continue or ESC to exit...");
         ALL_OFF;
         loop
            QGET (ANYKEY);
            if ANYKEY = ' ' then
               exit; -- Exit just this small entry loop
            elsif ANYKEY = ASCII . ESC then
               exit MAIN_LOOP; -- Exit from the main loop
            end if;
         end loop;
      end loop MAIN_LOOP;
      -- The following line closes the customer file and re-opens it
      -- for input and output.
      RESET (CUSTFILE, MODE => INOUT_FILE);
   end VIEW;

begin
   -- What follows is another standard Ada technique:
   -- A block is declared; a file is opened; if it existed previously,
   -- everything is OK and the block is exited; else, an exception is
   -- raised and a new file is created.
   begin
      OPEN (CUSTFILE, NAME => "CUSTOMER.DAT", MODE => INOUT_FILE);
   exception
      when NAME_ERROR =>
         CREATE (CUSTFILE, NAME => "CUSTOMER.DAT");
   end;
   loop
      SET_UP_SCREEN;
      BACKGROUND (4);
      BOX (0, 3, 79, 21);
      COLOR (3);
      CURSOR (60, 0);
      PUT ("Main menu");
      CURSOR (20, 8);
      PUT ("A - Add new customers to mailing list");
      CURSOR (20, 10);
      PUT ("M - Modify information on a customer");
      CURSOR (20, 12);
      PUT ("V - View mailing list");
      CURSOR (20, 14);
      PUT ("E - Exit program");
      BOX (5, 17, 75, 19);
      CURSOR (20, 18);
      INTENSITY;
      PUT ("Choose Add, Modify, View or Exit (A/M/V/E) => ");
      GET (CHOICE);
      ALL_OFF;
      case CHOICE is
         when 'a' | 'A' => ADD_CUSTOMER;
         when 'm' | 'M' => MODIFY_CUSTOMER;
         when 'v' | 'V' => VIEW;
         when 'e' | 'E' => exit;
         -- Insert your additional choices here
         when others =>
            CURSOR (20, 20);
            BLINK;
            PUT ("Incorrect choice.  Press any key ...");
            ALL_OFF;
            QGET (ANYKEY);
      end case;
   end loop;
   CLOSE (CUSTFILE);
   CURSOR (20, 20);
   PUT ("Thank you and have a nice day.");
exception
   when others =>
      ALL_OFF; -- Ensure black and white MS-DOS even if an error occurs
      raise; -- Let the run-time system report the exception to the user
end MAIL; -- End of program

