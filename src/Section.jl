#=
Methods to construct and act on Section type, which mirrors the functions of Neuron's Section type

Inputs:
sec - section containing node
x - ID of node to be created (range of 1 to nseg)
nseg - number of total segments in section

=#

function r_a_calc(sec::Section,x::Int64,nseg::Int64)
    
    #find location of other nodes on section in normalized units
    
    cent=(2*x-1)/(2*nseg)
    interval=Float64[(x-1)/nseg, x/nseg]
    
    #calc area, ri

    #only if pt3d>2. If not, then there is going to need to be special case stuff
    area=zeros(Float64,2)
    ri=zeros(Float64,2)
    volume=0.0
    
    arc3d=collect(Float64[sec.pt3d[i].arc for i=1:length(sec.pt3d)])

    first=findfirst(arc3d.>interval[1])-1
    mid=findfirst(arc3d.>cent)-1
    last=findnext(arc3d.>=interval[2],first)-1

    frac=interp_area(arc3d[first],interval[1],arc3d[first+1])

    diam=frac[1]*sec.pt3d[first].d+frac[2]*sec.pt3d[first+1].d
    height=frac[2]*arc3d[first+1]*sec.length
    
    for i=(first+1):mid
        area[1]+=frustrum_area(diam, sec.pt3d[i].d,height)
        ri[1]+=frustrum_resistance(diam,sec.pt3d[i].d,height,sec.Ra)
        diam=sec.pt3d[i].d
        height=arc3d[i+1]*sec.length
    end

    frac=interp_area(arc3d[mid], cent, arc3d[mid+1])

    diam=frac[1]*sec.pt3d[mid].d+frac[2]*sec.pt3d[mid+1].d
    height=frac[1]*arc3d[mid+1]*sec.length

    area[1]+=frustrum_area(sec.pt3d[mid].d,diam,height)
    ri[1]+=frustrum_resistance(sec.pt3d[mid].d,diam,height,sec.Ra)

    diam=sec.pt3d[mid+1].d
    height=frac[2]*arc3d[mid+1]*sec.length
    
    for i=(mid+2):last
        area[2]+=frustrum_area(diam,sec.pt3d[i].d,height)
        ri[2]+=frustrum_resistance(diam,sec.pt3d[i].d,height,sec.Ra)
        diam=sec.pt3d[i].d
        height=arc3d[i+1]*sec.length
    end

    frac=interp_area(arc3d[last], interval[2], arc3d[last+1])

    diam=frac[1]*sec.pt3d[last].d+frac[2]*sec.pt3d[last+1].d
    height=frac[1]*sec.pt3d[last+1].arc*sec.length

    area[2]+=frustrum_area(sec.pt3d[last].d,diam,height)
    ri[2]+=frustrum_resistance(sec.pt3d[last].d,diam,height,sec.Ra)

    (area, ri)
     
end

function frustrum_area(d1::Float64,d2::Float64,h::Float64)
    F=pi*(d1/2+d2/2)*sqrt((d1/2-d2/2)^2+h^2)
end

function frustrum_resistance(d1::Float64,d2::Float64,h::Float64,ri::Float64)
    R=ri*h/(pi*(d1/2)*(d2/2))
end

function interp_area(x1::Float64, x2::Float64, x3::Float64)
    frac1=(x2-x1)/(x3-x1)
    frac2=(x3-x2)/(x3-x1)

    [frac1,frac2]
end

function add_prop!(node::Node,prop::Prop)

    if sum([typeof(node.prop[i])==typeof(prop) for i=1:length(node.prop)])==0

        push!(node.prop,prop)
        
        for i=1:length(prop.nodevar)
            if !haskey(node.vars,prop.nodevar[i])
                node.vars[prop.nodevar[i]]=0.0
            end
        end
    else
        println("Property also exists in node. Not inserting")
    end
           
    nothing        
end

function change_nseg!(sec::Section,nseg::Int64)

    newnodes=Array(Node,0)
   
    for i=1:nseg
        push!(newnodes,Node(sec,i,nseg))
    end

    sec.pnode=newnodes

    nothing
    
end

function define_shape!(neuron::Neuron)

end

