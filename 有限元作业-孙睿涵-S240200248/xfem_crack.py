# -*- coding: mbcs -*-
from abaqus import *
from abaqusConstants import *
from caeModules import *
import os

def xfem_2d():
    # 初始化设置----------------------------------------------
    modelName = 'xfem_crack_2d'
    workDir = r'D:/Abaqus_Workspace/'  # 统一工作目录
    if not os.path.exists(workDir):
        os.makedirs(workDir)
    
    # 清理旧模型
    if modelName in mdb.models.keys():
        del mdb.models[modelName]
    myModel = mdb.Model(name=modelName)
    session.viewports['Viewport: 1'].setValues(displayedObject=None)

    # 几何参数-----------------------------------------------
    plateSize = 6.0       # 平板尺寸 (3x3x6)
    crackLength = 1.5     # 裂纹长度
    thickness = 1.0       # 厚度
    meshSize = 0.1        # 基础网格尺寸

    # 材料参数-----------------------------------------------
    E = 210e9             # 弹性模量 (Pa)
    nu = 0.3              # 泊松比
    sigma_max = 220e6     # 损伤起始应力 (Pa)
    Gf = 42200            # 断裂能 (J/m²)

    # 创建平板几何-------------------------------------------
    sketch = myModel.ConstrainedSketch(name='plateProfile', sheetSize=2*plateSize)
    sketch.rectangle((0, -plateSize/2), (plateSize/2, plateSize/2))
    plate = myModel.Part(name='Plate', dimensionality=TWO_D_PLANAR,
                        type=DEFORMABLE_BODY)
    plate.BaseShell(sketch=sketch)
    del myModel.sketches['plateProfile']

    # 定义材料与截面属性-------------------------------------
    myMaterial = myModel.Material(name='Steel')
    myMaterial.Elastic(table=((E, nu),))
    
    # 损伤准则设置 (修正参数名称)
    myMaterial.MaxPrincipalDamageInitiation(
        table=((sigma_max, ), ),
        temperatureDependency=OFF
    )
    myMaterial.maxPrincipalDamageInitiation.DamageEvolution(
        type=ENERGY,
        mixedModeBehavior=POWER_LAW,
        power=1.0,
        table=((Gf, Gf, Gf), )
    )
    myMaterial.maxPrincipalDamageInitiation.DamageStabilizationCohesive(
        cohesiveCoeff=0.001
    )
    
    # 创建截面属性
    myModel.HomogeneousSolidSection(name='PlateSection', 
                                   material='Steel', 
                                   thickness=thickness)
    plate.SectionAssignment(region=plate.Set(faces=plate.faces, name='AllFaces'),
                           sectionName='PlateSection')

    # 装配设置-----------------------------------------------
    myAssembly = myModel.rootAssembly
    plateInstance = myAssembly.Instance(name='PlateInst', part=plate, dependent=ON)

    # 裂纹定义 (修正XFEM设置方式)----------------------------
    # 创建裂纹几何集
    crackEdges = plateInstance.edges.findAt(((crackLength, 0.05, 0),))
    myAssembly.Set(edges=crackEdges, name='CrackSet')

    # 定义XFEM裂纹 (移除不必要的接触属性)
    myModel.Enrichment(
        name='CrackEnrichment',
        crackFront=myAssembly.sets['CrackSet'],
        crackTip=NO_CRACK_TIP,
        enrichmentType=CRACK
    )
    myModel.XFEMCrack(name='MainCrack', 
                     interactionProperty=XFEMDamageInitiation.STRESS,
                     diagnosticPrint=OFF)

    # 分析步设置---------------------------------------------
    myModel.StaticStep(name='Fracture', previous='Initial',
                      nlgeom=ON, maxNumInc=1000,
                      initialInc=0.01, minInc=1e-8, maxInc=0.1)

    # 场输出设置 (增加XFEM相关输出)
    myModel.FieldOutputRequest(name='XFEM_Output', 
                              variables=('S', 'E', 'U', 'STATUSXFEM', 'PHILSM'),
                              frequency=10)

    # 边界条件-----------------------------------------------
    # 固定左端
    leftEdge = plateInstance.edges.findAt(((0, 0, 0),))
    myAssembly.Set(edges=leftEdge, name='FixedEdge')
    myModel.EncastreBC(name='FixLeft', createStepName='Initial',
                      region=myAssembly.sets['FixedEdge'])

    # 右端施加位移载荷 (调整位移量)
    disp = 0.05 * plateSize  # 控制位移量为5%板长
    rightEdge = plateInstance.edges.findAt(((plateSize/2, 0, 0),))
    myAssembly.Set(edges=rightEdge, name='LoadEdge')
    myModel.DisplacementBC(name='Tension', createStepName='Fracture',
                          region=myAssembly.sets['LoadEdge'], u1=disp)

    # 网格划分优化-------------------------------------------
    # 全局种子
    plate.seedPart(size=meshSize, deviationFactor=0.05)
    
    # 裂纹附近局部细化
    crackRegion = plateInstance.edges.findAt(((crackLength, 0.05, 0),))
    myAssembly.Set(edges=crackRegion, name='CrackZone')
    plate.seedEdgeBySize(edges=crackRegion, size=meshSize/5, constraint=FINER)

    # 单元类型设置
    elemType = mesh.ElemType(elemCode=CPE4, elemLibrary=STANDARD)
    plate.setElementType(regions=plate.faces, elemTypes=(elemType,))
    plate.generateMesh()

    # 作业提交-----------------------------------------------
    jobName = 'XFEM_Analysis'
    mdb.Job(name=jobName, model=modelName, 
           numCpus=4, numDomains=4,  # 并行计算设置
           description='XFEM crack propagation analysis')
    
    # 自动提交并监控计算
    mdb.jobs[jobName].submit(consistencyChecking=OFF)
    mdb.jobs[jobName].waitForCompletion()

    # 后处理增强---------------------------------------------
    odbPath = os.path.join(workDir, jobName + '.odb')
    odb = session.openOdb(odbPath)
    session.viewports['Viewport: 1'].setValues(displayedObject=odb)
    
    # 自动生成结果报告
    session.writeFieldReport(
        fileName=os.path.join(workDir, 'Stress_Report.rpt'),
        append=OFF, sortItem='Node Label',
        odb=odb, step=0, frame=1,
        outputPosition=INTEGRATION_POINT,
        variable=(('S', INTEGRATION_POINT), ('STATUSXFEM', INTEGRATION_POINT))
    )
    
    # 保存模型
    mdb.saveAs(os.path.join(workDir, modelName))

# 执行函数
xfem_2d()