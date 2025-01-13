--재뉴어리 달마시안
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--not fully implemented
	local e1=MakeEff(c,"S")
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.con1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
end
function s.nfil1(c,sc,st,tp)
	return c:IsSetCard("재뉴어리",sc,st,tp)
end
function s.con1(e,g,gc,chkfnf)
	local mustg=nil
	local c=e:GetHandler()
	local tp=c:GetControler()
	if g==nil then
		return #(Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,nil,REASON_FUSION))==0
	end
	local chkf=chkfnf&0xff
	local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
	local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
	local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
	local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
	if notfusion then
		sumtype=0
	elseif contact then
		sumtype=MATERIAL_FUSION
	end
	local matcheck=e:GetValue()
	mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
	if contact then
		mustg:Clear()
	end
	local sub=not listedmats and (true or notfusion) and not contact
	local mg=g:Filter(s.nfil1,c,c,sumtype,tp)
	if not mg:Includes(mustg) or mustg:IsExists(aux.NOT(s.nfil1),1,nil,c,sumtype,tp) then
		return false
	end
	if gc then
		if type(gc)=="Card" then
			gc=Group.FromCards(gc)
		end
		if gc:IsExists(aux.NOT(Card.IsCanBeFusionMaterial),1,nil,c,sumtype)
			or gc:IsExists(aux.NOT(s.nfil1),1,nil,c,sumtype,tp) then
			return false
		end
		mustg:Merge(gc)
	end
	local sg=Group.CreateGroup()
	mg:Merge(mustg)
	return mg:IsExists(s.nfil1,101,nil,c,sumtype,tp)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
	local chkf=chkfnf&0xff
	local c=e:GetHandler()
	local tp=c:GetControler()
	local notfusion=(chkfnf&FUSPROC_NOTFUSION)~=0
	local contact=(chkfnf&FUSPROC_CONTACTFUS)~=0
	local listedmats=(chkfnf&FUSPROC_LISTEDMATS)~=0
	local sumtype=SUMMON_TYPE_FUSION|MATERIAL_FUSION
	if notfusion then
		sumtype=0
	elseif contact then
		sumtype=MATERIAL_FUSION
	end
	local matcheck=e:GetValue()
	local sub=not listedmats and (true or notfusion) and not contact
	local sg=Group.CreateGroup()
	local mg=eg:Filter(s.nfil1,c,c,sumtype,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,eg,tp,c,mg,REASON_FUSION)
	if contact then mustg:Clear() end
	if not mg:Includes(mustg) or mustg:IsExists(aux.NOT(s.nfil1),1,nil,c,sumtype,tp) then
		return false
	end
	if gc then
		if type(gc)=="Card" then
			gc=Group.FromCards(gc)
		end
		mustg:Merge(gc)
	end
	sg:Merge(mustg)
	local p=tp
	local sfhchk=false
	if not contact and Duel.IsPlayerAffectedByEffect(tp,511004008) and Duel.SelectYesNo(1-tp,65) then
		p=1-tp Duel.ConfirmCards(1-tp,mg)
		if mg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			sfhchk=true
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local sg=mg:FilterSelect(tp,s.nfil1,101,101,nil,c,sumtype,tp)
	if sfhchk then
		Duel.ShuffleHand(tp)
	end
	Duel.SetFusionMaterial(sg)
end