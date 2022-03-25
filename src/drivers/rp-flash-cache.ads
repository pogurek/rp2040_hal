package RP.Flash.Cache is
   procedure Enable;
   procedure Disable;
   procedure Power_Down;
   --  Power_Down implies Disable, cache state is retained while powered down

   procedure Flush
      (Wait : Boolean := True);
   --  If Wait is True, Flush blocks until the cache flush is complete,
   --  otherwise the cache is flushed asynchronously.
end RP.Flash.Cache;
