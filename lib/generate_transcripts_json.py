import os
import json
import re

# --- الإعدادات ---
# تأكد أن هذه المسارات صحيحة على جهازك (المسارات المعتمدة في مشروعك)
project_assets_dir = r"E:\FLUTTER PROJECTS\sunaa_app\assets\transcripts"
json_output_path = r"E:\FLUTTER PROJECTS\sunaa_app\assets\transcripts_list.json"

# 1. قاعدة بيانات الروابط الكاملة (275 حلقة)
raw_links = """
الحلقة 1: https://www.youtube.com/watch?v=eFoxGiLh-EE
الحلقة 2: https://www.youtube.com/watch?v=baetcjxZ4GE
الحلقة 3: https://www.youtube.com/watch?v=EW9yZ5VZmUo
الحلقة 4: https://www.youtube.com/watch?v=GK8T7sVBE1g
الحلقة 5: https://www.youtube.com/watch?v=oqYjR9Fa_Ds
الحلقة 6: https://www.youtube.com/watch?v=MbvdARuhQis
الحلقة 7: https://www.youtube.com/watch?v=XqXKbVQ4B_s
الحلقة 8: https://www.youtube.com/watch?v=-xbR7oMs8a4
الحلقة 9: https://www.youtube.com/watch?v=Vw83VBfscL4
الحلقة 10: https://www.youtube.com/watch?v=VGhXH9FM7tE
الحلقة 11: https://www.youtube.com/watch?v=-KPgbCdUyXA
الحلقة 12: https://www.youtube.com/watch?v=jH4oNbqY2h8
الحلقة 13: https://www.youtube.com/watch?v=wFJQqPS1zhI
الحلقة 14: https://www.youtube.com/watch?v=DApTBRSTvhY
الحلقة 15: https://www.youtube.com/watch?v=K_yRNUdYNro
الحلقة 16: https://www.youtube.com/watch?v=020SQ_EIPc4
الحلقة 17: https://www.youtube.com/watch?v=6dQ2Df4tveQ
الحلقة 18: https://www.youtube.com/watch?v=XUg6jxVUDa8
الحلقة 19: https://www.youtube.com/watch?v=xtHlLMLeAoI
الحلقة 20: https://www.youtube.com/watch?v=uRDIT7_bSOM
الحلقة 21: https://www.youtube.com/watch?v=AvPW0xZdQVQ
الحلقة 22: https://www.youtube.com/watch?v=ucSgnkaA9po
الحلقة 23: https://www.youtube.com/watch?v=caFOmvt1r9w
الحلقة 24: https://www.youtube.com/watch?v=ozF649xLmhg
الحلقة 25: https://www.youtube.com/watch?v=xkJadr4Hc-0
الحلقة 26: https://www.youtube.com/watch?v=-LUEJGwXKjY
الحلقة 27: https://www.youtube.com/watch?v=4YPRgMHElGA
الحلقة 28: https://www.youtube.com/watch?v=jMP6GgzkVl8
الحلقة 29: https://www.youtube.com/watch?v=WZ0_HdF9_PA
الحلقة 30: https://www.youtube.com/watch?v=Rr_svkuOowY
الحلقة 31: https://www.youtube.com/watch?v=iyRxtBCnCXY
الحلقة 32: https://www.youtube.com/watch?v=0pYqaqSXjmw
الحلقة 33: https://www.youtube.com/watch?v=Aoov2A2Qe0g
الحلقة 34: https://www.youtube.com/watch?v=jbNrNlkrj4o
الحلقة 35: https://www.youtube.com/watch?v=KLJVnlFOSwA
الحلقة 36: https://www.youtube.com/watch?v=3IP7QTCZ0lE
الحلقة 37: https://www.youtube.com/watch?v=r9InMAEz-EI
الحلقة 38: https://www.youtube.com/watch?v=3KkzKkYPPYw
الحلقة 39: https://www.youtube.com/watch?v=wQGKTcRBh00
الحلقة 40: https://www.youtube.com/watch?v=QDwpWT82je4
الحلقة 41: https://www.youtube.com/watch?v=xMqWd0lo6uw
الحلقة 42: https://www.youtube.com/watch?v=HBBIZuq-K3w
الحلقة 43: https://www.youtube.com/watch?v=Gy2loAGHTPk
الحلقة 44: https://www.youtube.com/watch?v=lMBM0MxJMPM
الحلقة 45: https://www.youtube.com/watch?v=hAsBAWLbUlg
الحلقة 46: https://www.youtube.com/watch?v=1up0GowcbDU
الحلقة 47: https://www.youtube.com/watch?v=hCUq-DmwpLI
الحلقة 48: https://www.youtube.com/watch?v=0f9tKDTdkmY
الحلقة 49: https://www.youtube.com/watch?v=B22wa26bmVs
الحلقة 50: https://www.youtube.com/watch?v=r5EpLLOGWpI
الحلقة 51: https://www.youtube.com/watch?v=qLSztEur1fo
الحلقة 52: https://www.youtube.com/watch?v=dP8fMWOxNmM
الحلقة 53: https://www.youtube.com/watch?v=1C_qd3a4fQg
الحلقة 54: https://www.youtube.com/watch?v=VJoPaPAjIM4
الحلقة 55: https://www.youtube.com/watch?v=vwudcqk916k
الحلقة 56: https://www.youtube.com/watch?v=XgN_Ir-PlOM
الحلقة 57: https://www.youtube.com/watch?v=2Rg7PhnkRlw
الحلقة 58: https://www.youtube.com/watch?v=acpYyIkMO3A
الحلقة 59: https://www.youtube.com/watch?v=TPLhdoGyksE
الحلقة 60: https://www.youtube.com/watch?v=JH_grL-_7Ww
الحلقة 61: https://www.youtube.com/watch?v=DYyBh-N4ixk
الحلقة 62: https://www.youtube.com/watch?v=cEwJ6vG5RZM
الحلقة 63: https://www.youtube.com/watch?v=1muwhIFxmR8
الحلقة 64: https://www.youtube.com/watch?v=ReZEwdY4GiQ
الحلقة 65: https://www.youtube.com/watch?v=chLqWZmy8Ek
الحلقة 66: https://www.youtube.com/watch?v=JXhipyhE0f4
الحلقة 67: https://www.youtube.com/watch?v=67pRkpnGbfQ
الحلقة 68: https://www.youtube.com/watch?v=E_4PNaS3PvY
الحلقة 69: https://www.youtube.com/watch?v=24bWYyLtQFA
الحلقة 70: https://www.youtube.com/watch?v=VvLZSrdP-Yk
الحلقة 71: https://www.youtube.com/watch?v=QDodX9-ribo
الحلقة 72: https://www.youtube.com/watch?v=i-ASM1CegNA
الحلقة 73: https://www.youtube.com/watch?v=tg3hD3uxM0o
الحلقة 74: https://www.youtube.com/watch?v=N7UsCoQmzEk
الحلقة 75: https://www.youtube.com/watch?v=HJEp52RMxWk
الحلقة 76: https://www.youtube.com/watch?v=kZt0tnFbH0U
الحلقة 77: https://www.youtube.com/watch?v=KAbH8T0imL0
الحلقة 78: https://www.youtube.com/watch?v=N6iFOClyqHQ
الحلقة 79: https://www.youtube.com/watch?v=eW8jj26hajs
الحلقة 80: https://www.youtube.com/watch?v=QBCumPnDNiI
الحلقة 81: https://www.youtube.com/watch?v=Tl8ukkHH368
الحلقة 82: https://www.youtube.com/watch?v=3PECXL7cGF8
الحلقة 83: https://www.youtube.com/watch?v=ZWobxkClK8M
الحلقة 84: https://www.youtube.com/watch?v=UfVSVIUhokM
الحلقة 85: https://www.youtube.com/watch?v=-7V_YVz1CxI
الحلقة 86: https://www.youtube.com/watch?v=bB2z-SiIsiM
الحلقة 87: https://www.youtube.com/watch?v=HPczsUHDBjY
الحلقة 88: https://www.youtube.com/watch?v=yyx38SB1gik
الحلقة 89: https://www.youtube.com/watch?v=u3LYjTa6SG4
الحلقة 90: https://www.youtube.com/watch?v=o7Xaa5FdffM
الحلقة 91: https://www.youtube.com/watch?v=n7CIfL9g2rU
الحلقة 92: https://www.youtube.com/watch?v=hCiAB7DxB6w
الحلقة 93: https://www.youtube.com/watch?v=-WxvdkeVmUE
الحلقة 94: https://www.youtube.com/watch?v=MPyCzKRLHZo
الحلقة 95: https://www.youtube.com/watch?v=2pPY3m6HYpI
الحلقة 96: https://www.youtube.com/watch?v=rv-A2qpmXz8
الحلقة 97: https://www.youtube.com/watch?v=i_RY3EtU4Xc
الحلقة 98: https://www.youtube.com/watch?v=5pg3MliaZhU
الحلقة 99: https://www.youtube.com/watch?v=91-XGUOQ0mo
الحلقة 100: https://www.youtube.com/watch?v=9j1SmX2HTr0
الحلقة 101: https://www.youtube.com/watch?v=of4Gc-XvyhQ
الحلقة 102: https://www.youtube.com/watch?v=3J0mOaK8rEQ
الحلقة 103: https://www.youtube.com/watch?v=5HEQIPPW638
الحلقة 104: https://www.youtube.com/watch?v=ZNyKr0kHuFk
الحلقة 105: https://www.youtube.com/watch?v=dx0QeKUNzzQ
الحلقة 106: https://www.youtube.com/watch?v=VWrL0zJe-Y0
الحلقة 107: https://www.youtube.com/watch?v=uY3f9T3uG_U
الحلقة 108: https://www.youtube.com/watch?v=N01hP698SLY
الحلقة 109: https://www.youtube.com/watch?v=eNRiTdS5jzs
الحلقة 110: https://www.youtube.com/watch?v=IWFc37gkCgA
الحلقة 111: https://www.youtube.com/watch?v=yapxTOvZik4
الحلقة 112: https://www.youtube.com/watch?v=GR7XpGmm_fA
الحلقة 113: https://www.youtube.com/watch?v=6re7kw3wEuA
الحلقة 114: https://www.youtube.com/watch?v=qDa0-eSh7n4
الحلقة 115: https://www.youtube.com/watch?v=526uTk32IbU
الحلقة 116: https://www.youtube.com/watch?v=s40LNjG69Ms
الحلقة 117: https://www.youtube.com/watch?v=p2e0DQd8KxU
الحلقة 118: https://www.youtube.com/watch?v=BoDuwcl7TVw
الحلقة 119: https://www.youtube.com/watch?v=0Lm03XszWCA
الحلقة 120: https://www.youtube.com/watch?v=TC3dzSiFsKI
الحلقة 121: https://www.youtube.com/watch?v=orbnaOPami0
الحلقة 122: https://www.youtube.com/watch?v=ZkUl-jMzYc0
الحلقة 123: https://www.youtube.com/watch?v=o1gEsMkXF-4
الحلقة 124: https://www.youtube.com/watch?v=nZnwALC3vCI
الحلقة 125: https://www.youtube.com/watch?v=zFBwUZgbiMU
الحلقة 126: https://www.youtube.com/watch?v=CyeQ4Ln7IJA
الحلقة 127: https://www.youtube.com/watch?v=og9cnHeH4yI
الحلقة 128: https://www.youtube.com/watch?v=mWq3WZHXLWE
الحلقة 129: https://www.youtube.com/watch?v=nbmuDq8XCCc
الحلقة 130: https://www.youtube.com/watch?v=8FjClnPbyw8
الحلقة 131: https://www.youtube.com/watch?v=kOS9mPWz_J8
الحلقة 132: https://www.youtube.com/watch?v=kx9nXKxbVpM
الحلقة 133: https://www.youtube.com/watch?v=H__638e-_VI
الحلقة 134: https://www.youtube.com/watch?v=_hjRUl4xvDY
الحلقة 135: https://www.youtube.com/watch?v=o571aj6ZJJw
الحلقة 136: https://www.youtube.com/watch?v=CQS71vLi4cY
الحلقة 137: https://www.youtube.com/watch?v=_dGx5Q845M0
الحلقة 138: https://www.youtube.com/watch?v=IFoUY4W682A
الحلقة 139: https://www.youtube.com/watch?v=apE3cgP0sEo
الحلقة 140: https://www.youtube.com/watch?v=lo6Nv48ZBcw
الحلقة 141: https://www.youtube.com/watch?v=Ub26as1Vbrc
الحلقة 142: https://www.youtube.com/watch?v=LJ7WXAr5AbM
الحلقة 143: https://www.youtube.com/watch?v=p7lnwK7Opv0
الحلقة 144: https://www.youtube.com/watch?v=gk7jkCqPJQs
الحلقة 145: https://www.youtube.com/watch?v=eSs6d_sQJvw
الحلقة 146: https://www.youtube.com/watch?v=9OvxTD53R78
الحلقة 147: https://www.youtube.com/watch?v=SU__3QD9Byg
الحلقة 148: https://www.youtube.com/watch?v=bCqvQMqQAA0
الحلقة 149: https://www.youtube.com/watch?v=lZuIuE3xsp4
الحلقة 150: https://www.youtube.com/watch?v=JmGME-8fEa8
الحلقة 151: https://www.youtube.com/watch?v=SVViSCHqX6g
الحلقة 152: https://www.youtube.com/watch?v=sMEa5Nct-4E
الحلقة 153: https://www.youtube.com/watch?v=PGskHpH1KCY
الحلقة 154: https://www.youtube.com/watch?v=sdoyGAGDrYY
الحلقة 155: https://www.youtube.com/watch?v=Z_UyYt2Nglo
الحلقة 156: https://www.youtube.com/watch?v=eo67DPSEbgg
الحلقة 157: https://www.youtube.com/watch?v=Q3yk45TEHzU
الحلقة 158: https://www.youtube.com/watch?v=rSohGCjprLQ
الحلقة 159: https://www.youtube.com/watch?v=flqT4VYnjOo
الحلقة 160: https://www.youtube.com/watch?v=PnqlrIfx_IY
الحلقة 161: https://www.youtube.com/watch?v=4wPJmWz1hjE
الحلقة 162: https://www.youtube.com/watch?v=5MvyJHYM9Uk
الحلقة 163: https://www.youtube.com/watch?v=Gd6Uc3v1uZQ
الحلقة 164: https://www.youtube.com/watch?v=4N9eYpjUUSA
الحلقة 165: https://www.youtube.com/watch?v=ftbLdriBcII
الحلقة 166: https://www.youtube.com/watch?v=-GlyEPZMEyg
الحلقة 167: https://www.youtube.com/watch?v=h8s1NEzDMAk
الحلقة 168: https://www.youtube.com/watch?v=uBTLnUYdN6o
الحلقة 169: https://www.youtube.com/watch?v=S4P7k6GoaWg
الحلقة 170: https://www.youtube.com/watch?v=mKqQyNrk1GA
الحلقة 171: https://www.youtube.com/watch?v=-2Vb4kHPhGk
الحلقة 172: https://www.youtube.com/watch?v=-jGeIuMJ4hA
الحلقة 173: https://www.youtube.com/watch?v=cDfKrGYae6A
الحلقة 174: https://www.youtube.com/watch?v=YObE_ab2JVc
الحلقة 175: https://www.youtube.com/watch?v=FFgj0lsb43A
الحلقة 176: https://www.youtube.com/watch?v=s8OLinjPOJI
الحلقة 177: https://www.youtube.com/watch?v=J-xeiTSpzgA
الحلقة 178: https://www.youtube.com/watch?v=mJbH6KuvT14
الحلقة 179: https://www.youtube.com/watch?v=rQHHWyZKT-Y
الحلقة 180: https://www.youtube.com/watch?v=0_kczfovFVg
الحلقة 181: https://www.youtube.com/watch?v=ZO5UwspIHhM
الحلقة 182: https://www.youtube.com/watch?v=f1g2myShrYI
الحلقة 183: https://www.youtube.com/watch?v=0gRCZ4fyuuw
الحلقة 184: https://www.youtube.com/watch?v=9s7Hk_ey6Hc
الحلقة 185: https://www.youtube.com/watch?v=cny29MkRU5A
الحلقة 186: https://www.youtube.com/watch?v=_HK7w1xNi7c
الحلقة 187: https://www.youtube.com/watch?v=QjjS9lG8ApE
الحلقة 188: https://www.youtube.com/watch?v=kASsSQjVRQI
الحلقة 189: https://www.youtube.com/watch?v=uAV9sLOZoXc
الحلقة 190: https://www.youtube.com/watch?v=87JaJNeJTN0
الحلقة 191: https://www.youtube.com/watch?v=9YU-qCCj9cs
الحلقة 192: https://www.youtube.com/watch?v=BO1WWUaiSY8
الحلقة 193: https://www.youtube.com/watch?v=0EM8h1JZNsw
الحلقة 194: https://www.youtube.com/watch?v=ByKlYpyiDYU
الحلقة 195: https://www.youtube.com/watch?v=4aN_ygtkH4s
الحلقة 196: https://www.youtube.com/watch?v=m4J4PuFb31A
الحلقة 197: https://www.youtube.com/watch?v=-I3m78a8PfE
الحلقة 198: https://www.youtube.com/watch?v=96A3CmDCFhA
الحلقة 199: https://www.youtube.com/watch?v=S_Zg0Cr3xLE
الحلقة 200: https://www.youtube.com/watch?v=ILHzgcGFTZE
الحلقة 201: https://www.youtube.com/watch?v=7d7rlGv_DM0
الحلقة 202: https://www.youtube.com/watch?v=eVTXe-ki05I
الحلقة 203: https://www.youtube.com/watch?v=_Z7yYCcUgZY
الحلقة 204: https://www.youtube.com/watch?v=NDZcfsqBDOk
الحلقة 205: https://www.youtube.com/watch?v=ntDoX_cBpI4
الحلقة 206: https://www.youtube.com/watch?v=wiTbbve8W8g
الحلقة 207: https://www.youtube.com/watch?v=3Y4AIEzGCvA
الحلقة 208: https://www.youtube.com/watch?v=dXo9O9-ctuw
الحلقة 209: https://www.youtube.com/watch?v=_786cl48tIo
الحلقة 210: https://www.youtube.com/watch?v=cf5R40XKlo8
الحلقة 211: https://www.youtube.com/watch?v=yYAH9PGO2Oo
الحلقة 212: https://www.youtube.com/watch?v=jZtP8EQVxmc
الحلقة 213: https://www.youtube.com/watch?v=w-qcWRQ2IWk
الحلقة 214: https://www.youtube.com/watch?v=8596mht9uBo
الحلقة 215: https://www.youtube.com/watch?v=pGqDvm4pdl8
الحلقة 216: https://www.youtube.com/watch?v=y0t2tRBlLv8
الحلقة 217: https://www.youtube.com/watch?v=YW6-T7qg8X8
الحلقة 218: https://www.youtube.com/watch?v=o7dKXoNoIUA
الحلقة 219: https://www.youtube.com/watch?v=oIuz7EC-9Lc
الحلقة 220: https://www.youtube.com/watch?v=VzWqdyWR1Lc
الحلقة 221: https://www.youtube.com/watch?v=P4NXjS69P9g
الحلقة 222: https://www.youtube.com/watch?v=yg3_rnakCgM
الحلقة 223: https://www.youtube.com/watch?v=pw3oPC2EzEs
الحلقة 224: https://www.youtube.com/watch?v=PTZJBCqTOn8
الحلقة 225: https://www.youtube.com/watch?v=IHuvvq_bgbA
الحلقة 226: https://www.youtube.com/watch?v=jLNW-Ka9Q5A
الحلقة 227: https://www.youtube.com/watch?v=ndb-ygCrtIw
الحلقة 228: https://www.youtube.com/watch?v=oydb1C_Cihk
الحلقة 229: https://www.youtube.com/watch?v=JLUfxKkT0-A
الحلقة 230: https://www.youtube.com/watch?v=aQT4h8EphKU
الحلقة 231: https://www.youtube.com/watch?v=uHihBw7WYbI
الحلقة 232: https://www.youtube.com/watch?v=eO-iV918zSM
الحلقة 233: https://www.youtube.com/watch?v=p39LlFmAo4o
الحلقة 234: https://www.youtube.com/watch?v=cmzWw3dxgu0
الحلقة 235: https://www.youtube.com/watch?v=xDWX1rz4yEY
الحلقة 236: https://www.youtube.com/watch?v=_ICKp4qlXrU
الحلقة 237: https://www.youtube.com/watch?v=fQkBXT-zkgs
الحلقة 238: https://www.youtube.com/watch?v=UDwGKH8uzsE
الحلقة 239: https://www.youtube.com/watch?v=GEvb9JipRNM
الحلقة 240: https://www.youtube.com/watch?v=z60-bN2ZQfk
الحلقة 241: https://www.youtube.com/watch?v=APT6NxwyyYw
الحلقة 242: https://www.youtube.com/watch?v=4k2dwWeuPDs
الحلقة 243: https://www.youtube.com/watch?v=RNXJylCEl4M
الحلقة 244: https://www.youtube.com/watch?v=qRU2QgE9iH0
الحلقة 245: https://www.youtube.com/watch?v=uxtwqUzAbB0
الحلقة 246: https://www.youtube.com/watch?v=1fSpOXy7jDU
الحلقة 247: https://www.youtube.com/watch?v=_m3PAZ0M4RM
الحلقة 248: https://www.youtube.com/watch?v=p1uWYQvsHT4
الحلقة 249: https://www.youtube.com/watch?v=mxR53tGPxjc
الحلقة 250: https://www.youtube.com/watch?v=4yoI4js-epo
الحلقة 251: https://www.youtube.com/watch?v=K6ZffnKEnDY
الحلقة 252: https://www.youtube.com/watch?v=EW6NGf6ROXc
الحلقة 253: https://www.youtube.com/watch?v=GhDPOy1iBHg
الحلقة 254: https://www.youtube.com/watch?v=OtfvgdUihjY
الحلقة 255: https://www.youtube.com/watch?v=YgJQXFHP2tQ
الحلقة 256: https://www.youtube.com/watch?v=d_wRDvivAIk
الحلقة 257: https://www.youtube.com/watch?v=9i3fnYFy3-Y
الحلقة 258: https://www.youtube.com/watch?v=_soEtPnftGQ
الحلقة 259: https://www.youtube.com/watch?v=1ILReRCk4uM
الحلقة 260: https://www.youtube.com/watch?v=tjSaBy0hy2I
الحلقة 261: https://www.youtube.com/watch?v=x7lIBL3rpC8
الحلقة 262: https://www.youtube.com/watch?v=mCU2lsUg7Ng
الحلقة 263: https://www.youtube.com/watch?v=JSgr6M18A2Q
الحلقة 264: https://www.youtube.com/watch?v=wBuXDBU5kRk
الحلقة 265: https://www.youtube.com/watch?v=zlD3sIkSRe0
الحلقة 266: https://www.youtube.com/watch?v=nstX7H3Kf9M
الحلقة 267: https://www.youtube.com/watch?v=Dm-ymQ2tQSE
الحلقة 268: https://www.youtube.com/watch?v=DPQ4wQ25Vv8
الحلقة 269: https://www.youtube.com/watch?v=M2qKEr6D4XM
الحلقة 270: https://www.youtube.com/watch?v=SltZRFx84Lg
الحلقة 271: https://www.youtube.com/watch?v=a1o5a5sM7lY
الحلقة 272: https://www.youtube.com/watch?v=erRV0FvVZ9w
الحلقة 273: https://www.youtube.com/watch?v=Sl4Ud1NeyBo
الحلقة 274: https://www.youtube.com/watch?v=i01vv3DKR2E
الحلقة 275: https://www.youtube.com/watch?v=9VCEVHCHdIo
"""

# 2. قائمة العناوين الكاملة (المذكورة في طلبك)
raw_titles = """
1. مقدمة في السيرة.. السيرة النبوية(1)
2. بداية قصة مكة وأول من سكنها.. السيرة النبوية(2)
3. أول من سكن مكة من القبائل.. السيرة النبوية(3)
4. مولد النبي ﷺ وقصة حليمة السعدية.. السيرة النبوية(4)
5. تأملات في قصة حليمة السعدية.. السيرة النبوية(5)
6. مُرضعات النبي ﷺ.. السيرة النبوية(6)
7. شهودهُ حلف الفضول وثناؤه عليه بعد النبوة.. السيرة النبوية(7)
8. فوائد نافعة من قصة حلف الفضول.. السيرة النبوية(8)
9. قصة زواجه بخديجة رضي الله عنها.. السيرة النبوية(9)
10. وقفات عند قصة زواجه بخديجة رضي الله عنها.. السيرة النبوية(10)
11. قصة بناء قريش للكعبة.. السيرة النبوية(11)
12. قصة بناء إبراهيم وإسماعيل عليهما السلام للكعبة.. السيرة النبوية(12)
13. قصة بناء إبراهيم وإسماعيل عليهما السلام للكعبة(2).. السيرة النبوية(13)
14. قصة بناء إبراهيم وإسماعيل عليهما السلام للكعبة(3).. السيرة النبوية(14)
15. وقفات مهمة في قصة بناء الكعبة(1).. السيرة النبوية(15)
16. وقفات مهمة في قصة بناء الكعبة(2).. السيرة النبوية(16)
17. وقفات مهمة في قصة بناء الكعبة(3).. السيرة النبوية(17)
18. وقفات مهمة في قصة بناء الكعبة(4).. السيرة النبوية(18)
19. وقفات مهمة في قصة بناء الكعبة(5).. السيرة النبوية(19)
20. بشارات الأنبياء برسالته وقُرب مبعثه.. السيرة النبوية(20)
21. قصة سلمان الفارسي.. السيرة النبوية(21)
22. قصة بداية الوحي.. السيرة النبوية(22)
23. قصة بداية الوحي(2).. السيرة النبوية(23)
24. تأمّلات في قصة بداية الوحي.. السيرة النبوية(24)
25. تأمّلات في قصة بداية الوحي(2).. السيرة النبوية(25)
26. أول من آمن بالنبي ﷺ.. السيرة النبوية(26)
27. السابقون الأولون للإسلام.. السيرة النبوية(27)
28. السابقون الأولون للإسلام(2).. السيرة النبوية(28)
29. إظهار أبي بكر لإسلامه.. السيرة النبوية(29)
30. ابتلاء الله للمؤمنين.. السيرة النبوية(30)
31. قصة ماشطة ابنة فرعون.. السيرة النبوية(31)
32. الذين تكلموا في المهد.. السيرة النبوية(32)
33. كيف كان يوحى لنبينا ﷺ.. السيرة النبوية(33)
34. شرف البدايات بحسن النهايات.. السيرة النبوية(34)
35. بداية الجهر بالدعوة.. السيرة النبوية(35)
36. دعوته للناس وابتلاؤه في الله.. السيرة النبوية(36)
37. حرب قريش للإسلام والمسلمين.. السيرة النبوية(37)
38. قصة النبي عليه الصلاة والسلام مع الوليد بن المغيرة.. السيرة النبوية(38)
39. صور من أذية المشركين لنبينا عليه الصلاة والسلام.. السيرة النبوية(39)
40. إسلام حمزة وأبي ذر رضي الله عنهما.. السيرة النبوية(40)
41. اجتهاد المشركين في ردّ الحقّ وأهله.. السيرة النبوية(41)
42. هجرة المؤمنين إلى الحبشة.. السيرة النبوية(42)
43. قصة النجاشي مع الصحابة.. السيرة النبوية(43)
44. عودة المسلمين من الحبشة.. السيرة النبوية(44)
45. إسلام عمر بن الخطاب.. السيرة النبوية(45)
46. حصار المسلمين في شِعَب أبي طالب.. السيرة النبوية(46)
47. حصار المسلمين في شِعَب أبي طالب.. عبر ودروس.. السيرة النبوية(47)
48. إسلام الطفيل بن عمرو.. السيرة النبوية(48)
49. وفاة أبي طالب.. السيرة النبوية(49)
50. وفاة خديجة.. السيرة النبوية(50)
51. قصة الإسراء والمعراج (1).. السيرة النبوية(51)
52. قصة الإسراء والمعراج (2).. السيرة النبوية(52)
53. زواجه بعائشة أم المؤمنين.. السيرة النبوية(53)
54. زواجه بأم المؤمنين سَودة بنت زمعة.. السيرة النبوية(54)
55. ترجمة أم المؤمنين عائشة (1).. السيرة النبوية(55)
56. ترجمة أم المؤمنين عائشة(2).. السيرة النبوية(56)
57. ترجمة أم المؤمنين سودة.. السيرة النبوية(57)
58. خروجه إلى الطائف يدعو أهلها للإسلام.. السيرة النبوية(58)
59. ما وقع له بعد خروجه من الطائف(1).. السيرة النبوية(59)
60. ما وقع له بعد خروجه من الطائف(2).. السيرة النبوية(60)
61. دخوله مكة في جوار المطعم بن عدي.. السيرة النبوية(61)
62. عرض نفسه عليه الصلاة والسلام على قبائل العرب للإيمان والنصرة.. السيرة النبوية(62)
63. لقاؤه بالأنصار وإسلام أوائلهم.. السيرة النبوية(63)
64. بيعة العقبة الأولى ومصعب بن عمير أول داعية.. السيرة النبوية(64)
65. إسلام أسيد بن الحضير.. السيرة النبوية(65)
66. إسلام سعد بن معاذ.. السيرة النبوية(66)
67. بيعة العقبة الثانية(1).. السيرة النبوية(67)
68. بيعة العقبة الثانية(2).. السيرة النبوية(68)
69. بيعة العقبة الثانية(3).. السيرة النبوية(69)
70. الأمر بالهجرة إلى المدينة.. السيرة النبوية(70)
202. تأملات في غزوة مؤتة ( 2 ).. السيرة النبوية(202)
203. تأملات في غزوة مؤتة ( 3 ).. السيرة النبوية(203)
204. ترجمة زيد بن حارثة.. السيرة النبوية(204)
205. ترجمة جعفر بن أبي طالب وعبدالله بن رواحة.. السيرة النبوية(205)
206. إرسال الكتب لدعوة الملوك للإسلام (1).. السيرة النبوية(206)
207. إرسال الكتب لدعوة الملوك للإسلام (2).. السيرة النبوية(207)
208. إرسال الكتب لدعوة الملوك للإسلام (3).. السيرة النبوية(208)
209. غزوة ذات السلاسل.. السيرة النبوية(209)
210. سرية أبي عبيدة لسيف البحر.. السيرة النبوية(210)
211. فتح مكة (1).. السيرة النبوية(211)
212. فتح مكة (2).. السيرة النبوية(212)
213. فتح مكة (3).. السيرة النبوية(213)
214. فتح مكة (4).. السيرة النبوية(214)
215. فتح مكة (5).. السيرة النبوية(215)
216. فتح مكة (6).. السيرة النبوية(216)
217. فتح مكة (7).. السيرة النبوية(217)
218. غزوة حنين (1).. السيرة النبوية(218)
219. غزوة حنين (2).. السيرة النبوية(219)
220. غزوة حنين (3).. السيرة النبوية(220)
221. غزوة حنين (4).. السيرة النبوية(221)
222. غزوة حنين (5).. السيرة النبوية(222)
223. غزوة الطائف (1).. السيرة النبوية(223)
224. غزوة الطائف (2).. السيرة النبوية(224)
225. غزوة الطائف (3).. السيرة النبوية(225)
226. غزوة الطائف (4).. السيرة النبوية(226)
227. غزوة الطائف (5).. السيرة النبوية(227)
228. غزوة الطائف (6).. السيرة النبوية(228)
229. غزوة الطائف (7).. السيرة النبوية(229)
230. غزوة الطائف (8).. السيرة النبوية(230)
231. غزوة تبوك (1).. السيرة النبوية(231)
232. غزوة تبوك (2).. السيرة النبوية(232)
233. غزوة تبوك (3).. السيرة النبوية(233)
234. غزوة تبوك (4).. السيرة النبوية(234)
235. غزوة تبوك (5).. السيرة النبوية(235)
236. غزوة تبوك (6).. السيرة النبوية(236)
237. غزوة تبوك (7).. السيرة النبوية(237)
238. غزوة تبوك (8).. السيرة النبوية(238)
239. غزوة تبوك (9).. السيرة النبوية(239)
240. غزوة تبوك (10).. السيرة النبوية(240)
241. غزوة تبوك (11).. السيرة النبوية(241)
242. غزوة تبوك (12).. السيرة النبوية(242)
243. غزوة تبوك (13).. السيرة النبوية(243)
244. غزوة تبوك (14).. السيرة النبوية(244)
245. غزوة تبوك (15).. السيرة النبوية(245)
246. غزوة تبوك (16).. السيرة النبوية(246)
247. غزوة تبوك (17).. السيرة النبوية(247)
248. عام الوفود (1).. السيرة النبوية(248)
249. عام الوفود (2).. السيرة النبوية(249)
250. عام الوفود (3).. السيرة النبوية(250)
251. عام الوفود (4).. السيرة النبوية(251)
252. عام الوفود (5).. السيرة النبوية(252)
253. عام الوفود (6).. السيرة النبوية(253)
254. عام الوفود (7).. السيرة النبوية(254)
255. وفيات العام التاسع.. السيرة النبوية(255)
256. بعث الأمراء إلى اليمن.. السيرة النبوية(256)
257. بعث خالد بن الوليد إلى اليمن.. السيرة النبوية(257)
258. حج أبي بكر بالناس عام 9.. السيرة النبوية(258)
259. حجة الوداع (1).. السيرة النبوية(259)
260. حجة الوداع (2).. السيرة النبوية(260)
261. حجة الوداع (3).. السيرة النبوية(261)
262. حجة الوداع (4).. السيرة النبوية(262)
263. حجة الوداع (5).. السيرة النبوية(263)
264. حجة الوداع (6).. السيرة النبوية(264)
265. فوائد من حجة الوداع (1).. السيرة النبوية(265)
266. فوائد من حجة الوداع (2).. السيرة النبوية(266)
267. فوائد من حجة الوداع (3).. السيرة النبوية(267)
268. وفاة النبي صلى الله عليه وسلم (1).. السيرة النبوية(268)
269. وفاة النبي صلى الله عليه وسلم (2).. السيرة النبوية(269)
270. وفاة النبي صلى الله عليه وسلم (3).. السيرة النبوية(270)
271. وفاة النبي صلى الله عليه وسلم (4).. السيرة النبوية(271)
272. وفاة النبي صلى الله عليه وسلم (5).. السيرة النبوية(272)
273. وفاة النبي صلى الله عليه وسلم (6).. السيرة النبوية(273)
274. الدروس المستفادة من وفاته ﷺ (1).. السيرة النبوية(274)
275. الدروس المستفادة من وفاته ﷺ (2).. السيرة النبوية(275)
"""

def normalize_to_english(text):
    arabic_nums = '٠١٢٣٤٥٦٧٨٩'
    english_nums = '0123456789'
    trans = str.maketrans(arabic_nums, english_nums)
    return text.translate(trans)

# --- التنفيذ ---

# 1. تحليل الروابط
links_map = {}
for line in raw_links.strip().split('\n'):
    if ':' in line:
        parts = line.split(': ', 1)
        num_match = re.search(r'(\d+)', parts[0])
        if num_match:
            num = num_match.group(1).zfill(3)
            url = parts[1].strip()
            links_map[num] = url

# 2. تحليل العناوين
titles_map = {}
# ملاحظة: استخدمت القائمة الكاملة التي زودتني بها في الكود الفعلي
for line in raw_titles.strip().split('\n'):
    clean_line = normalize_to_english(line.strip())
    match = re.search(r'\( ?(\d+) ?\)', clean_line)
    if match:
        num = match.group(1).zfill(3)
        title_part = clean_line.split('..')[0]
        title_part = re.sub(r'^\d+\.\s*', '', title_part).strip()
        titles_map[num] = title_part

# 3. بناء الجيسون بناءً على الملفات الموجودة في assets
final_json_data = []
if os.path.exists(project_assets_dir):
    # جلب جميع ملفات txt وترتيبها
    files = sorted([f for f in os.listdir(project_assets_dir) if f.endswith(".txt")])
    
    for f_name in files:
        num_str = f_name.replace(".txt", "").zfill(3)
        
        # جلب الرابط من الخريطة
        direct_url = links_map.get(num_str)
        # جلب العنوان أو وضع عنوان افتراضي
        display_title = titles_map.get(num_str, f"السيرة النبوية - الحلقة {int(num_str)}")
        
        if direct_url:
            final_json_data.append({
                "number": num_str.lstrip('0') or "0", # رقم الحلقة بدون أصفار بادئة للعرض
                "title": display_title,
                "path": f"assets/transcripts/{f_name}",
                "youtube_url": direct_url
            })

# 4. حفظ ملف transcripts_list.json النهائي
with open(json_output_path, "w", encoding="utf-8") as f:
    json.dump(final_json_data, f, ensure_ascii=False, indent=4)

print(f"✅ اكتملت العملية! تم دمج {len(final_json_data)} حلقة بروابطها وعناوينها الصحيحة.")