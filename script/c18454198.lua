--엔들리스 툰드라
local s,id=GetID()
function s.initial_effect(c)
	local e1=MakeEff(c,"A")
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	WriteEff(e1,1,"O")
	c:RegisterEffect(e1)
	local e2=MakeEff(c,"S")
	e2:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e2)
	local e3=MakeEff(c,"Qo","S")
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetCL(1,id)
	WriteEff(e3,3,"NC")
	local params={fusfilter=aux.FilterBoolFunction(Card.IsType,TYPE_TOON)
		,extrafil=s.fil3,extratg=s.tar3,extraop=s.op3}
	e3:SetTarget(Fusion.SummonEffTG(params))
	e3:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
		local ge1=MakeEff(c,"FC")
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(s.gop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=MakeEff(c,"FC")
		ge2:SetCode(EVENT_DISCARD)
		ge2:SetOperation(s.gop1)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_names={15259703}
function s.gop1(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		local pl=tc:GetPreviousLocation()
		if pl==LOCATION_MZONE and tc:GetPreviousTypeOnField()==TYPE_TOON then
			local p=tc:GetReasonPlayer()
			s[p]=s[p]+1
		elseif pl==LOCATION_HAND and tc:IsMonster() and tc:GetOriginalType()==TYPE_TOON then
			local p=tc:GetPreviousControler()
			s[p]=s[p]+1
		end
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=MakeEff(c,"FC")
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCL(1)
	e1:SetOperation(s.oop11)
	Duel.RegisterEffect(e1,tp)
end
function s.oofil11(c,e,tp,ct)
	return c:IsType(TYPE_TOON) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and c:IsLevelBelow(ct*2+4)
end
function s.oop11(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local ct=Duel.Draw(tp,s[tp],REASON_EFFECT)
	if ct>0 and Duel.GetLocCount(tp,"M")>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SMCard(tp,s.oofil11,tp,"D",0,1,1,nil,e,tp,ct)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.nfil3(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IEMCard(s.nfil3,tp,"O",0,1,nil)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.fil3(e,tp,mg)
	return Duel.GMGroup(Fusion.IsMonsterFilter(function(c)
			return c:IsType(TYPE_TOON) and c:IsAbleToRemove()
		end),tp,"G",0,nil),aux.TRUE
end
function s.tar3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return true
	end
	Duel.SPOI(0,CATEGORY_REMOVE,nil,0,tp,"G")
end
function s.op3(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end