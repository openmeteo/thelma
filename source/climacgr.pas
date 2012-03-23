{******************************************************************}
{                                                                  }
{  Thelma library                                                  }
{                                                                  }
{  Copyright (c) 2000-12 National Technical University of Athens   }
{                                                                  }
{******************************************************************}

{** Procedures for Climacograms. }

unit climacgr;

interface

uses ts;

{** Standard deviation for a series ATimeseries, aggregated to scale SScale.
    Original code by d.k. in VBA:
    Returns -1 if there are to few groups to calculate standard
    deviation.
    https://openmeteo.org/code/ticket/256
}
function AggrStDev(ATimeseries: TTimeseries; SScale: Integer): Real;

{** Standard deviation (all) for a series ATimeseries, aggregated to scale SScale.
    This is the second version and it considers all possible sums for a given
    scale.
    Original code by d.k. in VBA:
    https://openmeteo.org/code/ticket/256
}
function AggrStDevAll(ATimeseries: TTimeseries; SScale: Integer): Real;

implementation

uses math, stat2;

type
  TArrayOfReal = array of real;

function AggrStDev(ATimeseries: TTimeseries; SScale: Integer): Real;
var
  i, j, t, Count, NotNullCount: Integer;
  IgnoreFlag: Boolean;
  Sum: Real;
  aa: TArrayOfReal;
begin
  Count := ATimeseries.Count div SScale;
  NotNullCount = Count;
  aa := nil;
  try
    SetLength(aa, Count);
    t := 0;
    for i := 0 to Count - 1 do
    begin
      IgnoreFlag = False;
      Sum := 0;
      for j := i*SScale to (i+1)*SScale - 1 do
        if ATimeseries[j].IsNull then
          IgnoreFlag := True
        else
          Sum := Sum + ATimeseries[j].AsFloat;
      if IgnoreFlag then
      begin
        Dec(NotNullCount);
        Continue;
      end;
      aa[t] := Sum;
      Inc(t);
    end;
    if NotNullCount>1 then
      Result := sqrt(variance(aa, NotNullCount))/SScale
    else
      Result := -1;
  finally
    aa := nil;
  end;
end;

function AggrStDevAll(ATimeseries: TTimeseries; SScale: Integer): Real;
var
  i, j, k, Count: Integer;
  Sum: Real;
  b, aa: TArrayOfReal;
begin
  b := nil;
  try
    SetLength(b, SScale);
    for k := 0 to SScale - 1 do
    begin
      Count := (ATimeseries.Count - k) div SScale;
      aa := nil;
      try
        SetLength(aa, Count);
        for i := 0 to Count - 1 do
        begin
          Sum := 0;
          for j := i*SScale+k to (i+1)*SScale+k - 1 do
            if ATimeseries[j].IsNull then
              Continue
            else
              Sum := Sum + ATimeseries[j].AsFloat;
          aa[i] := Sum;
        end;
        b[k] := Sqrt(variance(aa, Count));
      finally
        aa := nil;
      end;
    end;
    Result := mean(b, SScale) / SScale;
  finally
    b := nil;
  end;
end;

end.
