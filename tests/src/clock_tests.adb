with AUnit.Assertions;
with RP.Clock;
with RP;

package body Clock_Tests is

   procedure Test_Initialize
      (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      use AUnit.Assertions;
      use RP;
      Nominal : constant Hertz := 125_000_000;
      Margin  : constant Hertz := 63; --  The frequency counter is only accurate to +/- 62.5 Hz
      Minimum : constant Hertz := Nominal - Margin;
      Maximum : constant Hertz := Nominal + Margin;
      F       : Hertz;
   begin
      RP.Clock.Initialize (12_000_000);
      F := RP.Clock.Frequency (RP.Clock.SYS);
      Assert (F in Minimum .. Maximum, "clk_sys is not in expected range : " & F'Image);
   end Test_Initialize;

   procedure Test_Enable
      (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      use AUnit.Assertions;
   begin
      RP.Clock.Disable (RP.Clock.PERI);

      Assert (not RP.Clock.Enabled (RP.Clock.PERI),
         "clk_peri should not be enabled");

      RP.Clock.Enable (RP.Clock.PERI);

      Assert (RP.Clock.Enabled (RP.Clock.PERI),
         "Unable to enable clk_peri");
      Assert (RP.Clock.Frequency (RP.Clock.PERI) = 125_000_000,
         "clk_peri is not running at 125 MHz");

      RP.Clock.Disable (RP.Clock.PERI);

      Assert (not RP.Clock.Enabled (RP.Clock.PERI),
         "Unable to disable clk_peri");
   end Test_Enable;

   procedure Test_Counter
      (T : in out AUnit.Test_Cases.Test_Case'Class)
   is
      use AUnit.Assertions;
   begin
      Assert (RP.Clock.Frequency (RP.Clock.SYS) = 125_000_000, "Unexpected clk_sys value");
      Assert (RP.Clock.Frequency
         (RP.Clock.SYS,
          Rounded  => False,
          Accuracy => 15)
          in (125_000_000 - 64) .. (125_000_000 + 64),
          "Fractional clk_sys out of range");
      Assert (RP.Clock.Frequency
         (RP.Clock.SYS,
          Rounded => False,
          Accuracy => 5)
          in (125_000_000 - 65535) .. (125_000_000 + 65535),
          "Low accuracy clk_sys out of range");
      RP.Clock.Enable (RP.Clock.USB);
      Assert (RP.Clock.Frequency
         (RP.Clock.USB,
          Rounded => False,
          Accuracy => 0)
          in (48_000_000 - 2_048_000) .. (48_000_000 + 2_048_000),
          "Low accuracy clk_usb out of range");
      Assert (RP.Clock.Frequency
         (RP.Clock.USB,
          Rounded => True)
          = 48_000_000,
          "Rounded clk_usb incorrect");
      RP.Clock.Disable (RP.Clock.USB);
      Assert (not RP.Clock.Enabled (RP.Clock.USB), "Failed to disable USB clock");
   end Test_Counter;

   overriding
   procedure Register_Tests
      (T : in out Clock_Test)
   is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Initialize'Access, "Initialize");
      Register_Routine (T, Test_Enable'Access, "Enable");
      Register_Routine (T, Test_Counter'Access, "Counter");
   end Register_Tests;

   overriding
   function Name
      (T : Clock_Test)
      return AUnit.Message_String
   is (AUnit.Format ("RP.Clock"));

end Clock_Tests;
