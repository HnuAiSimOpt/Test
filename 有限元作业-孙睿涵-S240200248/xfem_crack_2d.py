# -*- coding: mbcs -*-
# Do not delete the following import lines
from abaqus import *
from abaqusConstants import *
from caeModules import *

def xfem_2d():
    import section
    import regionToolset
    import displayGroupMdbToolset as dgm
    import part
    import material
    import assembly
    import step
    import interaction
    import load
    import mesh
    import optimization
    import job
    import sketch
    import visualization
    import xyPlot
    import displayGroupOdbToolset as dgo
    import connectorBehavior
    mdb.Model(name='xfem_crack_2d', modelType=STANDARD_EXPLICIT)
    session.viewports['Viewport: 1'].setValues(displayedObject=None)
    session.viewports['Viewport: 1'].setValues(displayedObject=None)
    del mdb.models['Model-1']
    session.viewports['Viewport: 1'].setValues(displayedObject=None)
    s = mdb.models['xfem_crack_2d'].ConstrainedSketch(name='__profile__', 
        sheetSize=6.0)
    g, v, d, c = s.geometry, s.vertices, s.dimensions, s.constraints
    s.setPrimaryObject(option=STANDALONE)
    s.rectangle(point1=(0.0, -3.0), point2=(3.0, 3.0))
    session.viewports['Viewport: 1'].view.setValues(nearPlane=3.9377, 
        farPlane=7.37601, width=13.9456, height=6.77559, cameraPosition=(
        1.34959, -0.531654, 5.65685), cameraTarget=(1.34959, -0.531654, 0))
    p = mdb.models['xfem_crack_2d'].Part(name='plate', dimensionality=TWO_D_PLANAR, 
        type=DEFORMABLE_BODY)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    p.BaseShell(sketch=s)
    s.unsetPrimaryObject()
    p = mdb.models['xfem_crack_2d'].parts['plate']
    session.viewports['Viewport: 1'].setValues(displayedObject=p)
    del mdb.models['xfem_crack_2d'].sketches['__profile__']
    s1 = mdb.models['xfem_crack_2d'].ConstrainedSketch(name='__profile__', 
        sheetSize=6.0)
    g, v, d, c = s1.geometry, s1.vertices, s1.dimensions, s1.constraints
    s1.setPrimaryObject(option=STANDALONE)
    s1.Line(point1=(0.0, 0.05), point2=(1.5, 0.05))
    s1.HorizontalConstraint(entity=g[2], addUndoState=False)
    session.viewports['Viewport: 1'].view.setValues(nearPlane=3.77026, 
        farPlane=7.54345, width=15.3038, height=7.43549, cameraPosition=(
        1.71224, -0.965947, 5.65685), cameraTarget=(1.71224, -0.965947, 0))
    p = mdb.models['xfem_crack_2d'].Part(name='crack', dimensionality=TWO_D_PLANAR, 
        type=DEFORMABLE_BODY)
    p = mdb.models['xfem_crack_2d'].parts['crack']
    p.BaseWire(sketch=s1)
    s1.unsetPrimaryObject()
    p = mdb.models['xfem_crack_2d'].parts['crack']
    session.viewports['Viewport: 1'].setValues(displayedObject=p)
    del mdb.models['xfem_crack_2d'].sketches['__profile__']
    session.viewports['Viewport: 1'].view.setValues(width=1.68708, height=0.781746, 
        viewOffsetX=0.0240429, viewOffsetY=-0.0159194)
    session.viewports['Viewport: 1'].partDisplay.setValues(sectionAssignments=ON, 
        engineeringFeatures=ON)
    session.viewports['Viewport: 1'].partDisplay.geometryOptions.setValues(
        referenceRepresentation=OFF)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    session.viewports['Viewport: 1'].setValues(displayedObject=p)
    mdb.models['xfem_crack_2d'].Material(name='elas')
    mdb.models['xfem_crack_2d'].materials['elas'].Elastic(table=((210000000000.0, 
        0.3), ))
    mdb.models['xfem_crack_2d'].materials['elas'].MaxpsDamageInitiation(table=((
        220000000.0, ), ))
    mdb.models['xfem_crack_2d'].materials['elas'].maxpsDamageInitiation.DamageEvolution(
        type=ENERGY, mixedModeBehavior=POWER_LAW, power=1.0, table=((42200.0, 
        42200.0, 42200.0), ))
    mdb.models['xfem_crack_2d'].materials['elas'].maxpsDamageInitiation.DamageStabilizationCohesive(
        cohesiveCoeff=0.001)
    session.viewports['Viewport: 1'].view.setValues(width=14.8637, height=6.88744, 
        viewOffsetX=-0.149595, viewOffsetY=-0.0734104)
    mdb.models['xfem_crack_2d'].HomogeneousSolidSection(name='solid', 
        material='elas', thickness=1.0)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    e = p.edges
    edges = e.getSequenceFromMask(mask=('[#1 ]', ), )
    p.Set(edges=edges, name='bottom')
    session.viewports['Viewport: 1'].view.setValues(width=14.238, height=6.5975, 
        viewOffsetX=0.188579, viewOffsetY=-0.29483)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    e = p.edges
    edges = e.getSequenceFromMask(mask=('[#4 ]', ), )
    p.Set(edges=edges, name='top')
    session.viewports['Viewport: 1'].view.setValues(nearPlane=11.2419, 
        farPlane=15.5909, width=17.3637, height=8.04589, viewOffsetX=1.05162, 
        viewOffsetY=-1.05833)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    f = p.faces
    faces = f.getSequenceFromMask(mask=('[#1 ]', ), )
    p.Set(faces=faces, name='ALL')
    p = mdb.models['xfem_crack_2d'].parts['plate']
    region = p.sets['ALL']
    p = mdb.models['xfem_crack_2d'].parts['plate']
    p.SectionAssignment(region=region, sectionName='solid', offset=0.0, 
        offsetType=MIDDLE_SURFACE, offsetField='', 
        thicknessAssignment=FROM_SECTION)
    a = mdb.models['xfem_crack_2d'].rootAssembly
    session.viewports['Viewport: 1'].setValues(displayedObject=a)
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(
        optimizationTasks=OFF, geometricRestrictions=OFF, stopConditions=OFF)
    a = mdb.models['xfem_crack_2d'].rootAssembly
    a.DatumCsysByDefault(CARTESIAN)
    p = mdb.models['xfem_crack_2d'].parts['crack']
    a.Instance(name='crack-1', part=p, dependent=ON)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    a.Instance(name='plate-1', part=p, dependent=ON)
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(
        adaptiveMeshConstraints=ON)
    mdb.models['xfem_crack_2d'].StaticStep(name='static', previous='Initial', 
        maxNumInc=10000, initialInc=0.005, minInc=1e-09, maxInc=0.01, 
        nlgeom=ON)
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(step='static')
    mdb.models['xfem_crack_2d'].fieldOutputRequests['F-Output-1'].setValues(
        variables=('S', 'PE', 'PEEQ', 'PEMAG', 'LE', 'U', 'RF', 'CF', 
        'CSTRESS', 'CDISP', 'PHILSM', 'PSILSM', 'STATUSXFEM'))
    mdb.models['xfem_crack_2d'].steps['static'].control.setValues(
        allowPropagation=OFF, resetDefaultValues=OFF, discontinuous=ON, 
        timeIncrementation=(8.0, 10.0, 9.0, 16.0, 10.0, 4.0, 12.0, 20.0, 6.0, 
        3.0, 50.0))
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(interactions=ON, 
        constraints=ON, connectors=ON, engineeringFeatures=ON, 
        adaptiveMeshConstraints=OFF)
    mdb.models['xfem_crack_2d'].ContactProperty('IntProp-1')
    a = mdb.models['xfem_crack_2d'].rootAssembly
    crackDomain = a.instances['plate-1'].sets['ALL']
    a = mdb.models['xfem_crack_2d'].rootAssembly
    e1 = a.instances['crack-1'].edges
    edges1 = e1.getSequenceFromMask(mask=('[#1 ]', ), )
    crackLocation = regionToolset.Region(edges=edges1)
    a = mdb.models['xfem_crack_2d'].rootAssembly
    a.engineeringFeatures.XFEMCrack(name='enr1', crackDomain=crackDomain, 
        interactionProperty='IntProp-1', crackLocation=crackLocation)
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(loads=ON, bcs=ON, 
        predefinedFields=ON, interactions=OFF, constraints=OFF, 
        engineeringFeatures=OFF)
    a = mdb.models['xfem_crack_2d'].rootAssembly
    region = a.instances['plate-1'].sets['top']
    mdb.models['xfem_crack_2d'].EncastreBC(name='BC-1', createStepName='static', 
        region=region, localCsys=None)
    a = mdb.models['xfem_crack_2d'].rootAssembly
    region = a.instances['plate-1'].sets['bottom']
    mdb.models['xfem_crack_2d'].DisplacementBC(name='BC-2', 
        createStepName='static', region=region, u1=0.2, u2=-0.15, ur3=UNSET, 
        amplitude=UNSET, fixed=OFF, distributionType=UNIFORM, fieldName='', 
        localCsys=None)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    session.viewports['Viewport: 1'].setValues(displayedObject=p)
    a = mdb.models['xfem_crack_2d'].rootAssembly
    session.viewports['Viewport: 1'].setValues(displayedObject=a)
    session.viewports['Viewport: 1'].view.setValues(nearPlane=11.4662, 
        farPlane=15.3666, width=15.9391, height=7.38577, viewOffsetX=0.66879, 
        viewOffsetY=0.0353864)
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(mesh=ON, loads=OFF, 
        bcs=OFF, predefinedFields=OFF, connectors=OFF)
    session.viewports['Viewport: 1'].assemblyDisplay.meshOptions.setValues(
        meshTechnique=ON)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    session.viewports['Viewport: 1'].setValues(displayedObject=p)
    session.viewports['Viewport: 1'].partDisplay.setValues(sectionAssignments=OFF, 
        engineeringFeatures=OFF, mesh=ON)
    session.viewports['Viewport: 1'].partDisplay.meshOptions.setValues(
        meshTechnique=ON)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    f = p.faces
    pickedRegions = f.getSequenceFromMask(mask=('[#1 ]', ), )
    p.setMeshControls(regions=pickedRegions, elemShape=QUAD, technique=STRUCTURED)
    elemType1 = mesh.ElemType(elemCode=CPE4, elemLibrary=STANDARD)
    elemType2 = mesh.ElemType(elemCode=CPE3, elemLibrary=STANDARD)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    f = p.faces
    faces = f.getSequenceFromMask(mask=('[#1 ]', ), )
    pickedRegions =(faces, )
    p.setElementType(regions=pickedRegions, elemTypes=(elemType1, elemType2))
    p = mdb.models['xfem_crack_2d'].parts['plate']
    e = p.edges
    pickedEdges = e.getSequenceFromMask(mask=('[#1 ]', ), )
    p.seedEdgeByNumber(edges=pickedEdges, number=30, constraint=FINER)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    e = p.edges
    pickedEdges = e.getSequenceFromMask(mask=('[#2 ]', ), )
    p.seedEdgeByNumber(edges=pickedEdges, number=60, constraint=FINER)
    session.viewports['Viewport: 1'].view.setValues(nearPlane=11.2921, 
        farPlane=15.5408, width=17.4412, height=8.10791, viewOffsetX=1.37721, 
        viewOffsetY=-0.745328)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    p.generateMesh()
    session.viewports['Viewport: 1'].view.setValues(width=15.3185, height=7.12111, 
        viewOffsetX=0.928789, viewOffsetY=-0.641645)
    a = mdb.models['xfem_crack_2d'].rootAssembly
    session.viewports['Viewport: 1'].setValues(displayedObject=a)
    a1 = mdb.models['xfem_crack_2d'].rootAssembly
    a1.regenerate()
    session.viewports['Viewport: 1'].view.setValues(nearPlane=11.6391, 
        farPlane=15.1937, width=11.7949, height=5.4831, viewOffsetX=0.861558, 
        viewOffsetY=0.139401)
    session.viewports['Viewport: 1'].partDisplay.setValues(sectionAssignments=ON, 
        engineeringFeatures=ON, mesh=OFF)
    session.viewports['Viewport: 1'].partDisplay.meshOptions.setValues(
        meshTechnique=OFF)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    session.viewports['Viewport: 1'].setValues(displayedObject=p)
    session.viewports['Viewport: 1'].view.setValues(nearPlane=11.0142, 
        farPlane=15.8187, width=15.3603, height=7.11753, viewOffsetX=0.928322, 
        viewOffsetY=-0.642693)
    p = mdb.models['xfem_crack_2d'].parts['plate']
    f = p.faces
    faces = f.getSequenceFromMask(mask=('[#1 ]', ), )
    region = regionToolset.Region(faces=faces)
    orientation=None
    mdb.models['xfem_crack_2d'].parts['plate'].MaterialOrientation(region=region, 
        orientationType=GLOBAL, axis=AXIS_3, 
        additionalRotationType=ROTATION_NONE, localCsys=None, fieldName='', 
        stackDirection=STACK_3)
    session.viewports['Viewport: 1'].partDisplay.setValues(sectionAssignments=OFF, 
        engineeringFeatures=OFF, mesh=ON)
    session.viewports['Viewport: 1'].partDisplay.meshOptions.setValues(
        meshTechnique=ON)
    a = mdb.models['xfem_crack_2d'].rootAssembly
    session.viewports['Viewport: 1'].setValues(displayedObject=a)
    a1 = mdb.models['xfem_crack_2d'].rootAssembly
    a1.regenerate()
    session.viewports['Viewport: 1'].assemblyDisplay.setValues(mesh=OFF)
    session.viewports['Viewport: 1'].assemblyDisplay.meshOptions.setValues(
        meshTechnique=OFF)
    mdb.Job(name='Job-1', model='xfem_crack_2d', description='', type=ANALYSIS, 
        atTime=None, waitMinutes=0, waitHours=0, queue=None, memory=90, 
        memoryUnits=PERCENTAGE, getMemoryFromAnalysis=True, 
        explicitPrecision=SINGLE, nodalOutputPrecision=SINGLE, echoPrint=OFF, 
        modelPrint=OFF, contactPrint=OFF, historyPrint=OFF, userSubroutine='', 
        scratch='', resultsFormat=ODB, numThreadsPerMpiProcess=1, 
        multiprocessingMode=DEFAULT, numCpus=1, numGPUs=0)
    mdb.jobs['Job-1'].submit(consistencyChecking=OFF)
    session.mdbData.summary()
    o3 = session.openOdb(name='D:/APP/Abaqus/temp/Job-1.odb')
    session.viewports['Viewport: 1'].setValues(displayedObject=o3)
    session.viewports['Viewport: 1'].makeCurrent()
    session.viewports['Viewport: 1'].odbDisplay.display.setValues(plotState=(
        CONTOURS_ON_DEF, ))
    mdb.saveAs(pathName='D:/APP/Abaqus/temp/xfem_crack_2d')


