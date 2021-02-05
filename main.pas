unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Timer1: TTimer;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private éŒ¾ }
    hDevice, hUniverse1, hUniverse2: integer;
    dmx_out: array[0..511] of byte;
    dmx_in: array[0..511] of byte;
  public
    { Public éŒ¾ }
  end;

var
  Form1: TForm1;

implementation

const
  DHC_OPEN       =  1;
  DHC_CLOSE			 =	2;
  DHC_DMXOUTOFF	 =	3;
  DHC_DMXOUT		 =	4;
  DHC_PORTREAD	 =	5;
  DHC_PORTCONFIG =  6;
  DHC_VERSION		 =  7;
  DHC_DMXIN			 =	8;
  DHC_INIT			 =	9;
  DHC_EXIT			 = 10;
  DHC_DMXSCODE	 = 11;
  DHC_DMX2ENABLE = 12;
  DHC_DMX2OUT		 = 13;
  DHC_SERIAL		 = 14;
  DHC_TRANSPORT	 = 15;
  DHC_DMXENABLE  = 16;
  DHC_DMX3ENABLE = 17;
  DHC_DMX3OUT		 = 18;
  DHC_DMX2IN		 = 19;
  DHC_DMX3IN  	 = 20;

  DHE_OK				  = 1;
  DHE_NOTHINGTODO	= 2;
  DHE_ERROR_COMMAND =	-1;
  DHE_ERROR_NOTOPEN =	-2;
  DHE_ERROR_ALREADYOPEN	= -12;


function DasUsbCommand(Command, Param: integer; Bloc: Pointer): integer;
  cdecl; external 'dashard2006.dll';

procedure DHDK_init(protocol: integer; aSoftwareName: Pointer);
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_init@8';
procedure DHDK_deinit;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_deinit@0';
function DHDK_enumerate: Bool;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_enumerate@0';
function DHDK_getDeviceCount: Integer;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_getDeviceCount@0';
function DHDK_getDevice(iDevice: integer): Integer;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_getDevice@4';
function DHDK_openDevice(hDevice: integer): Bool;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_openDevice@4';
procedure DHDK_closeDevice(hDevice: integer);
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_closeDevice@4';

function DHDK_getDeviceProtocol(hDevice: integer): Integer;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_getDeviceProtocol@4';
function DHDK_getDeviceTypeName(hDevice: integer; buffer: Pointer; size: integer): Bool;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_getDeviceTypeName@12';
function DHDK_getDeviceName(hDevice: integer; buffer: Pointer; size: integer): Bool;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_getDeviceName@12';

function DHDK_getDeviceSerial(hDevice: integer): Integer;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_getDeviceSerial@4';
function DHDK_getDmxUniverseCount(hDevice: integer): Integer;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_getDmxUniverseCount@4';

function DHDK_getDmxUniverse(hDevice: integer; univeNumber: integer): Integer;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_getDmxUniverse@8';
function DHDK_configureDmxUniverse(hDmxUniverse: integer; mode: integer): Integer;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_configureDmxUniverse@8';
function DHDK_sendDmx(hDmxUniverse: integer; dmxBuffer: Pointer; size: integer): Bool;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_sendDmx@12';
function DHDK_receiveDmx(hDmxUniverse: integer; dmxBuffer: Pointer; size: integer): Bool;
  stdcall; external 'LsHardDevKit.dll' name '_DHDK_receiveDmx@12';


{
function _: Integer;
  stdcall; external 'LsHardDevKit.dll' name '_@0';
}

{$R *.dfm}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (hDevice > 0) then
    DHDK_closeDevice(hDevice);
  DHDK_deinit;
{
  if (interface_open > 0) then
  begin
    DasUSBCommand(DHC_DMXOUTOFF, 0, nil);
    DasUSBCommand(DHC_CLOSE, 0, nil);
  end;
  DasUSBCommand(DHC_EXIT, 0, nil);
}
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i, r: integer;
  SoftwareName: PAnsiChar;
  buf: PAnsiChar;
begin
  hDevice := -1;
  for i := 0 to 511 do
  begin
    dmx_out[i] := 0;
    dmx_in[i] := 0;
  end;

  SoftwareName := 'ahoaho';
  DHDK_init(1, SoftwareName);
  memo1.Lines.add('init: ' + inttostr(r));

  if (DHDK_enumerate) then
    memo1.Lines.add('true')
  else
    memo1.Lines.add('false');

  r := DHDK_getDeviceCount;
  memo1.Lines.add('count: ' + inttostr(r));

  if (r > 0) then
  begin
    hDevice := DHDK_getDevice(0);
    memo1.Lines.add('get: ' + inttostr(hDevice));

    if (DHDK_openDevice(hDevice)) then
    begin
      r := DHDK_getDeviceProtocol(hDevice);
      memo1.Lines.add('pro: ' + inttostr(r));

      r := DHDK_getDeviceSerial(hDevice);
      memo1.Lines.add('serial: ' + inttostr(r));

      buf := AllocMem(100);
      DHDK_getDeviceTypeName(hDevice, buf, 100);
      memo1.Lines.add('name: ' + string(buf));

      r := DHDK_getDmxUniverseCount(hDevice);
      memo1.Lines.add('count: ' + inttostr(r));

      if (r >= 2) then
      begin
        hUniverse1 := DHDK_getDmxUniverse(hDevice, 0);
        memo1.Lines.add('univ1: ' + inttostr(hUniverse1));
        if (hUniverse1 > 0) then
          DHDK_configureDmxUniverse(hUniverse1, 1); // DHDK_DMXOUT

        hUniverse2 := DHDK_getDmxUniverse(hDevice, 1);
        memo1.Lines.add('univ2: ' + inttostr(hUniverse2));
        if (hUniverse2 > 0) then
          DHDK_configureDmxUniverse(hUniverse2, 2); // DHDK_DMXIN

        Timer1.Enabled := true;
      end;
    end;
  end;

{
  DasUSBCommand(DHC_INIT, 0, nil);
  interface_open := DasUSBCommand(DHC_OPEN, 0, nil);
  memo1.Lines.add('Open: ' + inttostr(interface_open));
  if (interface_open > 0) then
  begin
    DasUSBCommand(DHC_DMXOUTOFF, 0, nil);

    r := DasUSBCommand(DHC_VERSION, 0, nil);
    memo1.Lines.add('Version: ' + inttostr(r));

    r := DasUSBCommand(DHC_SERIAL, 0, nil);
    memo1.Lines.add('Serial: ' + inttostr(r));

    DasUSBCommand(DHC_DMX2ENABLE, 0, nil); // input

    Timer1.Enabled := true;
  end
  else
  begin
    memo1.Lines.add('Erreur : Ne trouve pas l''interface "Intelligent USB DMX"');
  end;
}
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i, r: integer;
begin
{
//  r := DasUSBCommand(DHC_PORTREAD, 0, nil);
//  memo1.Lines.add('Port: ' + inttohex(r, 4));

  r := DasUSBCommand(DHC_DMXOUT, 512, @dmx_out);
  memo1.Lines.add('dmxout: ' + inttostr(r) + ' ' + inttohex(dmx_out[0], 2));

  r := DasUSBCommand(DHC_DMX2IN, 512, @dmx_in);
  memo1.Lines.add('dmxin: ' + inttostr(r) + ' ' + inttohex(dmx_in[0], 2));
}

  dmx_out[0] := 255 - TrackBar1.Position;
  if (hUniverse1 > 0) then
  begin
    DHDK_sendDmx(hUniverse1, @dmx_out, 512);
//    memo1.Lines.add('dmxout: ' + inttohex(dmx_out[0], 2) + ' ' + inttohex(dmx_out[1], 2));
  end;

  if (hUniverse2 > 0) then
  begin
    DHDK_receiveDmx(hUniverse2, @dmx_in, 512);
//    memo1.Lines.add('dmxin: ' + inttohex(dmx_in[0], 2) + ' ' + inttohex(dmx_in[1], 2));
  end;

  label1.Caption := inttohex(dmx_out[0], 2) + ' ' + inttohex(dmx_in[0], 2);
end;

end.
