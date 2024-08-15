'''
checking polynominal response surface
'''

import parserst
import polyresponse
import numpy as np

rstls2 = parserst.parse_result_text("./data/sample_100.txt")

xpoints = np.ndarray((len(rstls2), 4), dtype=np.float64)
fwrpms = np.ndarray(len(rstls2), dtype=np.float64)
bwrpms = np.ndarray(len(rstls2), dtype=np.float64)
for i in range(len(rstls2)):
    damp : float = rstls2[i].paradict["dmpdp"]
    springrig : float = rstls2[i].paradict["sprrig"]
    balljtrig : float = rstls2[i].paradict["bjrigy"]
    bearrig : float = rstls2[i].paradict["berupk"]
    xpoints[i, 0] = damp
    xpoints[i, 1] = springrig
    xpoints[i, 2] = balljtrig
    xpoints[i, 3] = bearrig
    fw : float = rstls2[i].fwrpm[0]
    bw : float = rstls2[i].bwrpm[0]
    fwrpms[i] = fw
    bwrpms[i] = bw

fwresponse = polyresponse.PolyResponse2(xpoints, fwrpms, 3, 3)
bwresponse = polyresponse.PolyResponse2(xpoints, bwrpms, 3, 3)

#print(fwresponse.xmean)
#print(fwresponse.xstd)
#print(bwresponse.xmean)
#print(bwresponse.xstd)

rstls3 = parserst.parse_result_text("./data/sample_extra_10.txt")

xpoints = np.ndarray((len(rstls3), 4), dtype=np.float64)
nfwrpms = np.ndarray(len(rstls3), dtype=np.float64)
nbwrpms = np.ndarray(len(rstls3), dtype=np.float64)
for i in range(len(rstls3)):
    damp : float = rstls3[i].paradict["dmpdp"]
    springrig : float = rstls3[i].paradict["sprrig"]
    balljtrig : float = rstls3[i].paradict["bjrigy"]
    bearrig : float = rstls3[i].paradict["berupk"]
    xpoints[i, 0] = damp
    xpoints[i, 1] = springrig
    xpoints[i, 2] = balljtrig
    xpoints[i, 3] = bearrig
    fw : float = rstls3[i].fwrpm[0]
    bw : float = rstls3[i].bwrpm[0]
    nfwrpms[i] = fw
    nbwrpms[i] = bw
fwrpmhat = np.ndarray(len(rstls3), dtype=np.float64)
bwrpmhat = np.ndarray(len(rstls3), dtype=np.float64)
for i in range(len(rstls3)):
    fwrpmhat[i] = fwresponse(xpoints[i, :])
    bwrpmhat[i] = bwresponse(xpoints[i, :])
fwmean : float = fwrpms.mean()
bwmean : float = bwrpms.mean()
fwsst : float = ((nfwrpms - fwmean) ** 2).sum()
bwsst : float = ((nbwrpms - bwmean) ** 2).sum()
fwres : float = ((nfwrpms - fwrpmhat) ** 2).sum()
bwres : float = ((nbwrpms - bwrpmhat) ** 2).sum()
rsquarefw = 1.0 - fwres / fwsst
rsquarebw = 1.0 - bwres / bwsst

'''
print("fwrpmhat")
print(fwrpmhat)
print("fwrpms")
print(nfwrpms)
print("bwrpmhat")
print(bwrpmhat)
print("bwrpms")
print(nbwrpms)
'''
print("R square of forward critical velocity")
print(rsquarefw)
print("R square of backward critical velocity")
print(rsquarebw)

print("Expressions")
print("FW")
print(fwresponse.express())
print("BW")
print(bwresponse.express())
print("FW latex expression")
print(fwresponse.to_latex())
print("BW latex expression")
print(bwresponse.to_latex())

'''
fwresponse.to_excel("fwresponse.xlsx")
bwresponse.to_excel("bwresponse.xlsx")
'''
'''
R square of forward critical velocity
0.9926682208731632
R square of backward critical velocity
0.9875523386360219
Expressions
FW
x[0] -= 55.00000000000003
x[0] /= 26.24188186156556
x[1] -= 175.49999999999997
x[1] /= 101.76018632984868
x[2] -= 450000.00000000006
x[2] /= 204103.52558995443
x[3] -= 289999.9999999999
x[3] /= 122462.1153539726
(733.9510727991106) + (-0.1597186840711502) * x[3] ** 1 + (18.847819084682836) * x[2] ** 1 + (-9.22784681270646) * x[1] ** 1 + (230.5637285898129) * x[0] ** 1 + (-6.356620804290913) * x[3] ** 2 + (1.1577981460552218) * x[2] ** 1 * x[3] ** 1 + (-7.1899873420666065) * x[2] ** 2 + (2.8293145998329416) * x[1] ** 1 * x[3] ** 1 + (0.7700818485607268) * x[1] ** 1 * x[2] ** 1 + (-0.5133303796228353) * x[1] ** 2 + (17.432867405745235) * x[0] ** 1 * x[3] ** 1 + (0.6816394145160306) * x[0] ** 1 * x[2] ** 1 + (-1.8406496111421622) * x[0] ** 1 * x[1] ** 1 + (35.46748625071656) * x[0] ** 2 + (3.799526197734617) * x[3] ** 3 + (-3.8362747452662838) * x[2] ** 1 * x[3] ** 2 + (-1.1524418381419395) * x[2] ** 2 * x[3] ** 1 + (0.9413754853201203) * x[2] ** 3 + (2.36256984869142) * x[1] ** 1 * x[3] ** 2 + (0.908749940560882) * x[1] ** 1 * x[2] ** 1 * x[3] ** 1 + (-3.0346515378175956) * x[1] ** 1 * x[2] ** 2 + (-1.2250964789764682) * x[1] ** 2 * x[3] ** 1 + (-3.0450110799883725) * x[1] ** 2 * x[2] ** 1 + (6.367806110188598) * x[1] ** 3 + (-7.64200409896665) * x[0] ** 1 * x[3] ** 2 + (-2.156279329205942) * x[0] ** 1 * x[2] ** 1 * x[3] ** 1 + (4.878415183315034) * x[0] ** 1 * x[2] ** 2 + (-2.137052347638171) * x[0] ** 1 * x[1] ** 1 * x[3] ** 1 + (0.895947817997457) * x[0] ** 1 * x[1] ** 1 * x[2] ** 1 + (-4.89476559287121) * x[0] ** 1 * x[1] ** 2 + (8.41277222906809) * x[0] ** 2 * x[3] ** 1 + (-6.799829350820744) * x[0] ** 2 * x[2] ** 1 + (-3.4533039976652695) * x[0] ** 2 * x[1] ** 1 + (-32.833417025933706) * x[0] ** 3
BW
x[0] -= 55.00000000000003
x[0] /= 26.24188186156556
x[1] -= 175.49999999999997
x[1] /= 101.76018632984868
x[2] -= 450000.00000000006
x[2] /= 204103.52558995443
x[3] -= 289999.9999999999
x[3] /= 122462.1153539726
(673.5868448118678) + (-20.447406370475658) * x[3] ** 1 + (39.34833628171579) * x[2] ** 1 + (-14.617979790030255) * x[1] ** 1 + (196.88544791967837) * x[0] ** 1 + (-5.497152178164618) * x[3] ** 2 + (11.653633920817311) * x[2] ** 1 * x[3] ** 1 + (-12.259810685404318) * x[2] ** 2 + (4.585369992687639) * x[1] ** 1 * x[3] ** 1 + (1.9793758171407476) * x[1] ** 1 * x[2] ** 1 + (3.7700199978073874) * x[1] ** 2 + (10.38300853386952) * x[0] ** 1 * x[3] ** 1 + (8.892423227135252) * x[0] ** 1 * x[2] ** 1 + (-0.47982516126305064) * x[0] ** 1 * x[1] ** 1 + (44.43422235062982) * x[0] ** 2 + (6.159532956911316) * x[3] ** 3 + (-6.207699488072127) * x[2] ** 1 * x[3] ** 2 + (-0.39622898394897604) * x[2] ** 2 * x[3] ** 1 + (0.7489347515311486) * x[2] ** 3 + (7.443783236536236) * x[1] ** 1 * x[3] ** 2 + (-3.754402836046959) * x[1] ** 1 * x[2] ** 1 * x[3] ** 1 + (-7.99778245781573) * x[1] ** 1 * x[2] ** 2 + (-1.1197399119625142) * x[1] ** 2 * x[3] ** 1 + (-6.000357067326344) * x[1] ** 2 * x[2] ** 1 + (5.325179390357793) * x[1] ** 3 + (-7.75161785041496) * x[0] ** 1 * x[3] ** 2 + (0.8940912467129739) * x[0] ** 1 * x[2] ** 1 * x[3] ** 1 + (8.56559488365121) * x[0] ** 1 * x[2] ** 2 + (-1.8132290529617427) * x[0] ** 1 * x[1] ** 1 * x[3] ** 1 + (-2.3872506200811223) * x[0] ** 1 * x[1] ** 1 * x[2] ** 1 + (-3.628751862921069) * x[0] ** 1 * x[1] ** 2 + (14.142799339749173) * x[0] ** 2 * x[3] ** 1 + (-9.517470813583683) * x[0] ** 2 * x[2] ** 1 + (0.921833444785968) * x[0] ** 2 * x[1] ** 1 + (-24.04936296078096) * x[0] ** 3
FW latex expression
x_{1} -= 55.00000000000003
x_{1} /= 26.24188186156556
x_{2} -= 175.49999999999997
x_{2} /= 101.76018632984868
x_{3} -= 450000.00000000006
x_{3} /= 204103.52558995443
x_{4} -= 289999.9999999999
x_{4} /= 122462.1153539726
733.951-0.160x_{4}+18.848x_{3}-9.228x_{2}+230.564x_{1}-6.357x_{4}^{2} +1.158x_{3}x_{4}-7.190x_{3}^{2} +2.829x_{2}x_{4}+0.770x_{2}x_{3}-0.513x_{2}^{2} +17.433x_{1}x_{4}+0.682x_{1}x_{3}-1.841x_{1}x_{2}+35.467x_{1}^{2} +3.800x_{4}^{3} -3.836x_{3}x_{4}^{2} -1.152x_{3}^{2} x_{4}+0.941x_{3}^{3} +2.363x_{2}x_{4}^{2} +0.909x_{2}x_{3}x_{4}-3.035x_{2}x_{3}^{2} -1.225x_{2}^{2} x_{4}-3.045x_{2}^{2} x_{3}+6.368x_{2}^{3} -7.642x_{1}x_{4}^{2} -2.156x_{1}x_{3}x_{4}+4.878x_{1}x_{3}^{2} -2.137x_{1}x_{2}x_{4}+0.896x_{1}x_{2}x_{3}-4.895x_{1}x_{2}^{2} +8.413x_{1}^{2} x_{4}-6.800x_{1}^{2} x_{3}-3.453x_{1}^{2} x_{2}-32.833x_{1}^{3}
BW latex expression
x_{1} -= 55.00000000000003
x_{1} /= 26.24188186156556
x_{2} -= 175.49999999999997
x_{2} /= 101.76018632984868
x_{3} -= 450000.00000000006
x_{3} /= 204103.52558995443
x_{4} -= 289999.9999999999
x_{4} /= 122462.1153539726
673.587-20.447x_{4}+39.348x_{3}-14.618x_{2}+196.885x_{1}-5.497x_{4}^{2} +11.654x_{3}x_{4}-12.260x_{3}^{2} +4.585x_{2}x_{4}+1.979x_{2}x_{3}+3.770x_{2}^{2} +10.383x_{1}x_{4}+8.892x_{1}x_{3}-0.480x_{1}x_{2}+44.434x_{1}^{2} +6.160x_{4}^{3} -6.208x_{3}x_{4}^{2} -0.396x_{3}^{2} x_{4}+0.749x_{3}^{3} +7.444x_{2}x_{4}^{2} -3.754x_{2}x_{3}x_{4}-7.998x_{2}x_{3}^{2} -1.120x_{2}^{2} x_{4}-6.000x_{2}^{2} x_{3}+5.325x_{2}^{3} -7.752x_{1}x_{4}^{2} +0.894x_{1}x_{3}x_{4}+8.566x_{1}x_{3}^{2} -1.813x_{1}x_{2}x_{4}-2.387x_{1}x_{2}x_{3}-3.629x_{1}x_{2}^{2} +14.143x_{1}^{2} x_{4}-9.517x_{1}^{2} x_{3}+0.922x_{1}^{2} x_{2}-24.049x_{1}^{3}
'''