		MC68030
; Pulsars.asm
; geschrieben von Patrick Klie
		include	"lvo/exec.i"
		include	"lvo/intuition.i"
		include	"lvo/graphics.i"
		include	"lvo/mathieeesingbas.i"
		include	"lvo/mathieeesingtrans.i"
		include	"intuition/screens.i"
		include	"graphics/gfxbase.i"
		include	"startup2"
Versionsstring:	dc.b	"$VER: PulsarsAGA 1.0 (15.9.95)",0
		cnop	0,4
;Width		equ	320
;Height		equ	256
Width		equ	640
Height		equ	512
Depth		equ	8
AnzFarben	equ	1<<Depth
maxAnzErreger	equ	8
TRUE		equ	1
FALSE		equ	0

begin:
		lea	SysBase(pc),a0
		move.l	4.w,(a0)
		lea	GFXName(pc),a1
		moveq	#39,d0
		movea.l	SysBase(pc),a6
		jsr	_LVOOpenLibrary(a6)
		lea	GFXBase(pc),a0
		move.l	d0,(a0)
		beq	quit
		movea.l	d0,a0
		move.b	gb_ChipRevBits0(a0),d0
		and.b	#$f,d0				; AGA-Chipsatz
		cmp.b	#$f,d0
		bne	Close_GFX			; nicht: raus
Open_Int:
		lea	IntName(pc),a1
		moveq	#39,d0
		movea.l	SysBase(pc),a6
		jsr	_LVOOpenLibrary(a6)
		lea	IntBase(pc),a0
		move.l	d0,(a0)
		beq	Close_GFX
Open_MathIeeeSingBas:
		lea	MathIeeeSingBasName(pc),a1
		moveq	#37,d0
		movea.l	SysBase(pc),a6
		jsr	_LVOOpenLibrary(a6)
		lea	MathIeeeSingBasBase(pc),a0
		move.l	d0,(a0)
		beq	Close_Int
Open_MathIeeeSingTrans:
		lea	MathIeeeSingTransName(pc),a1
		moveq	#37,d0
		movea.l	SysBase(pc),a6
		jsr	_LVOOpenLibrary(a6)
		lea	MathIeeeSingTransBase(pc),a0
		move.l	d0,(a0)
		beq	Close_MathIeeeSingBas

		moveq	#4,d0
		movea.l	MathIeeeSingBasBase(pc),a6
		jsr	_LVOIEEESPFlt(a6)
Open_Screen:
		suba.l	a0,a0
		lea	Screen_Tags(pc),a1
		movea.l	IntBase(pc),a6
		jsr	_LVOOpenScreenTagList(a6)
		lea	Screen1(pc),a0
		move.l	d0,(a0)
		beq	Close_MathIeeeSingTrans
		lea	Window_Tags+4(pc),a0
		move.l	d0,(a0)
Open_Window:
		suba.l	a0,a0
		lea	Window_Tags(pc),a1
		movea.l	IntBase(pc),a6
		jsr	_LVOOpenWindowTagList(a6)
		lea	Window1(pc),a0
		move.l	d0,(a0)
		beq	Close_Screen
		lea	RastPort1(pc),a1
		movea.l	d0,a0
		move.l	wd_RPort(a0),(a1)
		lea	UserPort1(pc),a1
		move.l	wd_UserPort(a0),(a1)
		movea.l	RastPort1(pc),a1
		move.l	#255,d0
		movea.l	GFXBase(pc),a6
		jsr	_LVOSetAPen(a6)
;-----------------------------------------------------------------------------
		moveq	#maxAnzErreger-1,d7
		lea     Coords(pc),a5
Warten:
		movea.l	UserPort1(pc),a0
		movea.l	SysBase(pc),a6
		jsr	_LVOWaitPort(a6)

		movea.l	UserPort1(pc),a0
		movea.l	SysBase(pc),a6
		jsr	_LVOGetMsg(a6)
		tst.l	d0
		beq.s	Warten
		movea.l	d0,a1
		move.l	im_Class(a1),d3
		move.w	im_MouseX(a1),d4
		move.w	im_MouseY(a1),d5
		move.w	im_Code(a1),d6
		jsr	_LVOReplyMsg(a6)
		cmpi.l	#IDCMP_MOUSEBUTTONS,d3
		beq.s	Maustaste
		cmpi.l	#IDCMP_MOUSEMOVE,d3
		beq.s	Refresh_Coords
weiter:
		dbra	d7,Warten
		bra	Malen
Maustaste:
		cmpi.w	#MENUDOWN,d6
		beq.s	Malen
		cmpi.w	#SELECTDOWN,d6
		bne	Warten
Merken:
		move.w	d4,(a5)+	; Koordinaten speichern
		move.w	d5,(a5)+
		lea	AnzErreger(pc),a0
		addq.w	#1,(a0)
		bra.s	weiter
Refresh_Coords:
		lea	String1+7(pc),a0
		moveq	#0,d2
		move.w	d4,d2
		bsr	decl
		lea	String2+7(pc),a0
		moveq	#0,d2
		move.w	d5,d2
		bsr	decl

		movea.l	RastPort1(pc),a1
		moveq	#0,d0
		move.w	#Height-10,d1
		movea.l	GFXBase(pc),a6
		jsr	_LVOMove(a6)
		lea	String1(pc),a0
		movea.l	RastPort1(pc),a1
		moveq	#String2-String1,d0
		jsr	_LVOText(a6)

		movea.l	RastPort1(pc),a1
		moveq	#100,d0
		move.w	#Height-10,d1
		movea.l	GFXBase(pc),a6
		jsr	_LVOMove(a6)
		lea	String2(pc),a0
		movea.l	RastPort1(pc),a1
		moveq	#String2-String1,d0
		jsr	_LVOText(a6)
		bra	Warten
;-----------------------------------------------------------------------------
Malen:
		move.w	AnzErreger(pc),d0
		beq	Close_Window
		movea.l	MathIeeeSingBasBase(pc),a6
		moveq	#0,d0
		move.w	AnzErreger(pc),d0
		jsr	_LVOIEEESPFlt(a6)
		move.l	d0,d4
		moveq	#0,d0
		move.w	Farbenhalbe(pc),d0
		movea.l	MathIeeeSingBasBase(pc),a6
		jsr	_LVOIEEESPFlt(a6)
		move.l	d4,d1
		jsr	_LVOIEEESPDiv(a6)
		lea	Koeffizient(pc),a0
		move.l	d0,(a0)

		moveq	#-1,d6
.Loop:
		addq.w	#1,d6
		cmp.w	#Height,d6
		beq	.weiter
		moveq	#-1,d7
.Loop2:
		addq.w	#1,d7
		cmp.w	#Width,d7
		beq	.Loop
		moveq	#0,d5
		move.w	AnzErreger(pc),d5
		subq.l	#1,d5
		lea	Coords(pc),a5
.Loop3:						; nun alle Erreger durchlaufen
		movea.l	MathIeeeSingBasBase(pc),a6
		moveq	#0,d0
		move.w	(a5)+,d0
		jsr	_LVOIEEESPFlt(a6)
		move.l	d0,d4
		moveq	#0,d0
		move.w	d7,d0
		jsr	_LVOIEEESPFlt(a6)
		move.l	d4,d1
		jsr	_LVOIEEESPSub(a6)
		move.l	d0,d1
		jsr	_LVOIEEESPMul(a6)
		move.l	d0,d4

		moveq	#0,d0
		move.w	(a5)+,d0
		jsr	_LVOIEEESPFlt(a6)
		move.l	d0,d3
		moveq	#0,d0
		move.w	d6,d0
		jsr	_LVOIEEESPFlt(a6)
		move.l	d3,d1
		jsr	_LVOIEEESPSub(a6)
		move.l	d0,d1
		jsr	_LVOIEEESPMul(a6)
		move.l	d4,d1
		jsr	_LVOIEEESPAdd(a6)

		movea.l	MathIeeeSingTransBase(pc),a6
		jsr	_LVOIEEESPSqrt(a6)

;		move.l	#$40000000,d1		; strecken um 2
;		move.l	#$40400000,d1		; strecken um 3
		move.l	#$40800000,d1		; strecken um 4

		movea.l	MathIeeeSingBasBase(pc),a6
		jsr	_LVOIEEESPDiv(a6)

		movea.l	MathIeeeSingTransBase(pc),a6
		jsr	_LVOIEEESPSin(a6)
		move.l	d0,d1
		move.l	Koeffizient(pc),d0
		movea.l	MathIeeeSingBasBase(pc),a6
		jsr	_LVOIEEESPMul(a6)
		move.l	Koeffizient(pc),d1
		movea.l	MathIeeeSingBasBase(pc),a6
		jsr	_LVOIEEESPAdd(a6)
		movea.l	MathIeeeSingBasBase(pc),a6
		jsr	_LVOIEEESPFix(a6)
		lea	Farbe(pc),a0
		add.l	d0,(a0)
		dbra	d5,.Loop3

		move.l	Farbe(pc),d0
		cmp.l	#256,d0
		bne	.weiter2
		move.l	#255,d0
.weiter2:
		movea.l	RastPort1(pc),a1
		movea.l	GFXBase(pc),a6
		jsr	_LVOSetAPen(a6)
		lea	Farbe(pc),a0
		clr.l	(a0)

		move.w	d7,d0
		move.w	d6,d1
		movea.l	RastPort1(pc),a1
		movea.l	GFXBase(pc),a6
		jsr	_LVOWritePixel(a6)
		bra	.Loop2
.weiter:
		movea.l	UserPort1(pc),a0
		movea.l	SysBase(pc),a6
		jsr	_LVOWaitPort(a6)
		movea.l	UserPort1(pc),a0
		movea.l	SysBase(pc),a6
		jsr	_LVOGetMsg(a6)
		tst.l	d0
		beq.s	.weiter
		movea.l	d0,a1
		move.l	im_Class(a1),d2
		move.w	im_Code(a1),d3
		jsr	_LVOReplyMsg(a6)
		cmpi.l	#IDCMP_MOUSEBUTTONS,d2
		bne.s	.weiter
		cmpi.w	#SELECTDOWN,d3
		bne.s	.weiter
Close_Window:
		movea.l	Window1(pc),a0
		movea.l	IntBase(pc),a6
		jsr	_LVOCloseWindow(a6)
Close_Screen:
		movea.l	Screen1(pc),a0
		movea.l	IntBase(pc),a6
		jsr	_LVOCloseScreen(a6)
Close_MathIeeeSingTrans:
		movea.l	MathIeeeSingTransBase(pc),a1
		movea.l	SysBase(pc),a6
		jsr	_LVOCloseLibrary(a6)
Close_MathIeeeSingBas:
		movea.l	MathIeeeSingBasBase(pc),a1
		movea.l	SysBase(pc),a6
		jsr	_LVOCloseLibrary(a6)
Close_Int:
		movea.l	IntBase(pc),a1
		movea.l	SysBase(pc),a6
		jsr	_LVOCloseLibrary(a6)
Close_GFX:
		movea.l	GFXBase(pc),a1
		movea.l	SysBase(pc),a6
		jsr	_LVOCloseLibrary(a6)
quit:
		moveq	#0,d0
		rts
;Unterprogramme--------------------------------------------------------------
decl:
; wandelt eine Zahl unter Berücksichtigung des Vorzeichens in ASCII-String um
; Übergabeparameter:
; d2: Zahl
; a0: Adresse, an der der String abgelegt werden soll

		movem.l	a2/d2-d3,-(sp)
		movea.l	a0,a2
		tst.l	d2
		beq.s	iszero
plus:
		moveq	#3,d0
		movea.l	a2,a0
		lea	pwrof10(PC),a1
next:
		moveq	#"0",d1
dec:
		addq	#1,d1
		sub.l	(a1),d2
		bcc.s	dec
		subq	#1,d1
		add.l	(a1),d2
		move.b	d1,(a0)+
		lea	4(a1),a1
		dbra	d0,next
		movea.l	a2,a0
rep:
		move.b	#" ",(a0)+
		cmp.b	#"0",(a0)
		beq	rep
done:
		movem.l	(sp)+,a2/d2-d3
		rts
iszero:
		move.b	#" ",(a0)+
		move.b	#" ",(a0)+
		move.b	#" ",(a0)+
		move.b	#"0",(a0)
		bra.s	done
pwrof10:	
		dc.l	1000
		dc.l	100
		dc.l	10
		dc.l	1
;Datenbereich----------------------------------------------------------------
SysBase:	ds.l	1
GFXBase:	ds.l	1
IntBase:	ds.l	1
MathIeeeSingBasBase:	ds.l	1
MathIeeeSingTransBase:	ds.l	1

Screen_Tags:
		dc.l	SA_Left,0
		dc.l	SA_Top,0
		dc.l	SA_Width,Width
		dc.l	SA_Height,Height
		dc.l	SA_Depth,Depth
		dc.l	SA_DisplayID,DBLPALHIRESFF_KEY
;		dc.l	SA_DisplayID,LORES_KEY
		dc.l	SA_Colors32,ColorSpec1
		dc.l	SA_Interleaved,TRUE
		dc.l	SA_Quiet,TRUE
		dc.l	SA_AutoScroll,TRUE
		dc.l	SA_Overscan,1
		dc.l	TAG_DONE
Window_Tags:
		dc.l	WA_CustomScreen,0
		dc.l	WA_Left,0
		dc.l	WA_Top,0
		dc.l	WA_Width,Width
		dc.l	WA_Height,Height
		dc.l	WA_Activate,TRUE
		dc.l	WA_Borderless,TRUE
		dc.l	WA_RMBTrap,TRUE
		dc.l	WA_NoCareRefresh,TRUE
		dc.l	WA_IDCMP,IDCMP_MOUSEMOVE!IDCMP_MOUSEBUTTONS
		dc.l	WA_ReportMouse,TRUE
		dc.l	TAG_DONE

Screen1:	ds.l	1
Window1:	ds.l	1
RastPort1:	ds.l	1
UserPort1:	ds.l	1

Coords:		ds.w	2*maxAnzErreger	;Koordinaten der Erreger
AnzErreger:	dc.w	0
Farbenhalbe:	dc.w	AnzFarben/2
Koeffizient:	ds.l	1	; als SP-Zahl
Farbe:		ds.l	1	; diese wird für jeden Punkt berechnet

ColorSpec1:
		dc.w	256
		dc.w	0
		include	"ASRC:Pulsars/Palette3.i"
		dc.l	0

GFXName:	dc.b	"graphics.library",0
IntName:	dc.b	"intuition.library",0
MathIeeeSingBasName:	dc.b	"mathieeesingbas.library",0
MathIeeeSingTransName:	dc.b	"mathieeesingtrans.library",0
String1:	dc.b	"X-Pos: 0000"
String2:	dc.b	"Y-Pos: 0000"

		END
