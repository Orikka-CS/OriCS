--[ Nosferatu ]
local s,id=GetID()
function s.initial_effect(c)

	YuL.NosferatuDR(c,1000,1500)
	
	local e1=MakeEff(c,"FTo","H")
	e1:SetD(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCL(1,id)
	WriteEff(e1,1,"TO")
	c:RegisterEffect(e1)
	
	local e2=MakeEff(c,"Qo","M")
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCL(1,{id,1})
	e2:SetCost(Cost.SelfTribute)
	WriteEff(e2,2,"TO")
	c:RegisterEffect(e2)

	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
	end)
	
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if r&REASON_EFFECT~=0 or r&REASON_BATTLE~=0 then
		s[ep]=s[ep]+ev
	end
end

function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r&(REASON_BATTLE+REASON_EFFECT)~=0
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,ev)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,ev,REASON_EFFECT,true)
		Duel.Damage(tp,ev,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end

function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=math.floor(s[tp]/4000)
	if chk==0 then return ct>=1 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.floor(s[tp]/4000)
	Duel.Draw(tp,ct,REASON_EFFECT)
end
