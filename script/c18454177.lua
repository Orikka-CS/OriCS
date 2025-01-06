--검은 실×황홀
local s,id=GetID()
function s.initial_effect(c)
	s.register_black_thread()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.con1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tar1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.afil1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tar2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re then
		return false
	end
	local rc=re:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and (rc:IsType(TYPE_XYZ) or rc:IsSetCard(0xc05))
end
function s.afil1(c)
	return c:IsType(TYPE_XYZ) or not c:IsSummonLocation(LOCATION_EXTRA)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(10000)
	return true
end
function s.cfil11(c,e,tp,chain,ec)
	if c:IsSetCard(SET_NUMBER) or not c:IsType(TYPE_XYZ)
		or not c:IsRankBelow(8)
		or not c:IsAbleToGraveAsCost()
		or Duel.IsExistingMatchingCard(s.cfil12,tp,LOCATION_GRAVE,0,1,nil,c:GetCode()) then
		return false
	end
	local eff={c:GetCardEffect(511002571)}
	for _,teh in ipairs(eff) do
		local te=teh:GetLabelObject()
		local con=te:GetCondition()
		local cost=te:GetCost()
		local tg=te:GetTarget()
		local res=false
		if te:GetCode()==EVENT_CHAINING then
			if chain>0 then
				local ce=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
				local cc=ce:GetHandler()
				local cg=Group.FromCards(cc)
				local cp=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_PLAYER)
				if (not con or con(e,tp,cg,cp,chain,ce,REASON_EFFECT,cp))
					and (not tg or tg(e,tp,cg,cp,chain,ce,REASON_EFFECT,cp,0)) then
					aux.BlackThreadUsing=true
					aux.BlackThreadHandler=nil
					local cochk=not cost or cost(e,tp,cg,cp,chain,ce,REASON_EFFECT,cp,0)
					aux.BlackThreadUsing=false
					aux.BlackThreadHandler=nil
					if cochk then
						res=true
					end
				end
			end
		elseif te:GetCode()==EVENT_FREE_CHAIN
			or te:IsHasType(EFFECT_TYPE_IGNITION) then
			if (not con or con(e,tp,eg,ep,ev,re,r,rp))
				and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)) then
				aux.BlackThreadUsing=true
				aux.BlackThreadHandler=nil
				local cochk=not cost or cost(e,tp,eg,ep,ev,re,r,rp,0)
				aux.BlackThreadUsing=false
				aux.BlackThreadHandler=nil
				if cochk then
					res=true
				end
			end
		else
			local tres,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
			if tres
				and (not con or con(e,tp,teg,tep,tev,tre,tr,trp))
				and (not tg or tg(e,tp,teg,tep,tev,tre,tr,trp,0)) then
				aux.BlackThreadUsing=true
				aux.BlackThreadHandler=nil
				local cochk=not cost or cost(e,tp,teg,tep,tev,tre,tr,trp,0)
				aux.BlackThreadUsing=false
				aux.BlackThreadHandler=nil
				if cochk then
					res=true
				end
			end
		end
		if res then
			return true
		end
	end
	return false
end
function s.cfil12(c,code)
	return c:IsCode(code)
end
function s.ttar11(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
function s.tfil1(e,c)
	return c:GetOriginalType()&TYPE_XYZ==0
end
function s.tar1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	end
	if chk==0 then
		if e:GetLabel()~=10000 then
			return false
		end
		e:SetLabel(0)
		local chain=Duel.GetCurrentChain()
		return Duel.IsExistingMatchingCard(s.cfil11,tp,LOCATION_EXTRA,0,1,nil,e,tp,chain,c)
			and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.ttar11)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.addTempLizardCheck(c,tp,s.tfil1)
	e:SetLabel(0)
	local chain=Duel.GetCurrentChain()-1
	local g=Duel.SelectMatchingCard(tp,s.cfil11,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,chain,c)
	Duel.SendtoGrave(g,REASON_COST)
	local tc=g:GetFirst()
	local off=1
	local ops={}
	local opval={}
	local chain=Duel.GetCurrentChain()-1
	local i=1
	local eff={tc:GetCardEffect(511002571)}
	repeat
		local te=eff[i]:GetLabelObject()
		local res=false
		local con=te:GetCondition()
		local co=te:GetCost()
		local tg=te:GetTarget()
		if te:GetCode()==EVENT_CHAINING then
			if chain>0 then
				local ce=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
				local cc=ce:GetHandler()
				local cg=Group.FromCards(cc)
				local cp=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_PLAYER)
				if (not con or con(te,tp,cg,cp,chain,ce,REASON_EFFECT,cp))
					and (not tg or tg(te,tp,cg,cp,chain,ce,REASON_EFFECT,cp,0)) then
					aux.BlackThreadUsing=true
					aux.BlackThreadHandler=nil
					local cochk=not cost or cost(te,tp,cg,cp,chain,ce,REASON_EFFECT,cp,0)
					aux.BlackThreadUsing=false
					aux.BlackThreadHandler=nil
					if cochk then
						res=true
					end
				end
			end
		elseif te:GetCode()==EVENT_FREE_CHAIN or te:IsHasType(EFFECT_TYPE_IGNITION) then
			if (not con or con(te,tp,eg,ep,ev,re,r,rp))
				and (not tg or tg(te,tp,eg,ep,ev,re,r,rp,0)) then
				aux.BlackThreadUsing=true
				aux.BlackThreadHandler=nil
				local cochk=not cost or cost(te,tp,eg,ep,ev,re,r,rp,0)
				aux.BlackThreadUsing=false
				aux.BlackThreadHandler=nil
				if cochk then
					res=true
				end
			end
		else
			local tres,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
			if tres
				and (not con or con(te,tp,teg,tep,tev,tre,tr,trp))
				and (not tg or tg(te,tp,teg,tep,tev,tre,tr,trp,0)) then
				aux.BlackThreadUsing=true
				aux.BlackThreadHandler=nil
				local cochk=not cost or cost(te,tp,teg,tep,tev,tre,tr,trp,0)
				aux.BlackThreadUsing=false
				aux.BlackThreadHandler=nil
				if cochk then
					res=true
				end
			end
		end
		if res then
			ops[off]=te:GetDescription()
			opval[off-1]=te
			off=off+1
		end
		i=i+1
	until not eff[i]
	local ae=nil
	if off==2 then
		ae=opval[0]
	else
		local op=Duel.SelectOption(tp,table.unpack(ops))
		ae=opval[op]
	end
	e:SetCategory(ae:GetCategory())
	e:SetProperty(ae:GetProperty())
	local cost=ae:GetCost()
	if cost then
		if ae:GetCode()==EVENT_CHAINING then
			local ce=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
			local cc=ce:GetHandler()
			local cg=Group.FromCards(cc)
			local cp=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_PLAYER)
			aux.BlackThreadUsing=true
			aux.BlackThreadHandler=nil
			cost(e,tp,cg,cp,chain,ce,REASON_EFFECT,cp,1)
			aux.BlackThreadUsing=false
			aux.BlackThreadHandler=nil
		elseif ae:GetCode()==EVENT_FREE_CHAIN or ae:IsHasType(EFFECT_TYPE_IGNITION) then
			aux.BlackThreadUsing=true
			aux.BlackThreadHandler=nil
			cost(e,tp,eg,ep,ev,re,r,rp,1)
			aux.BlackThreadUsing=false
			aux.BlackThreadHandler=nil
		else
			local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(ae:GetCode(),true)
			aux.BlackThreadUsing=true
			aux.BlackThreadHandler=nil
			cost(e,tp,teg,tep,tev,tre,tr,trp,1)
			aux.BlackThreadUsing=false
			aux.BlackThreadHandler=nil
		end
	end
	local tg=ae:GetTarget()
	if ae:GetCode()==EVENT_CHAINING then
		local ce=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
		local cc=ce:GetHandler()
		local cg=Group.FromCards(cc)
		local cp=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_PLAYER)
		if tg then
			tg(e,tp,cg,cp,chain,ce,REASON_EFFECT,cp,1)
		end
	elseif ae:GetCode()==EVENT_FREE_CHAIN or ae:IsHasType(EFFECT_TYPE_IGNITION) then
		if tg then
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		end
	else
		local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(ae:GetCode(),true)
		if tg then
			tg(e,tp,teg,tep,tev,tre,tr,trp,1)
		end
	end
	ae:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(ae)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetLabelObject()
	if not ae then
		return
	end
	local chain=Duel.GetCurrentChain()-1
	e:SetLabelObject(ae:GetLabelObject())
	local op=ae:GetOperation()
	if ae:GetCode()==EVENT_CHAINING then
		local ce=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
		local cc=ce:GetHandler()
		local cg=Group.FromCards(cc)
		local cp=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_PLAYER)
		if op then
			op(e,tp,cg,cp,chain,ce,REASON_EFFECT,cp)
		end
	elseif ae:GetCode()==EVENT_FREE_CHAIN then
		if op then
			op(e,tp,eg,ep,ev,re,r,rp)
		end
	else
		local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(ae:GetCode(),true)
		if op then
			op(e,tp,teg,tep,tev,tre,tr,trp)
		end
	end
end
function s.cfil2(c)
	return c:IsSetCard(0xc05) and c:IsAbleToGraveAsCost()
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cfil2,tp,LOCATION_HAND,0,1,c)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfil2,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tfil2(c)
	return c:IsCode(18454183) and not c:IsForbidden()
end
function s.tar2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tfil2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.tfil2,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		if Duel.IsPlayerCanDraw(tp,1,REASON_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

function s.register_black_thread()

	if not aux.BlackThreadCheck then

		aux.BlackThreadCheck=true
		aux.BlackThreadUsing=false
		aux.BlackThreadHandler=nil

		local ccroc=Card.CheckRemoveOverlayCard
		local diemc=Duel.IsExistingMatchingCard
		--local gie=Group.IsExists
		local dgl=Duel.GetLP

		function Card.CheckRemoveOverlayCard(card,player,count,reason)

			if not aux.BlackThreadUsing then
				return ccroc(card,player,count,reason)
			else
				return diemc(Card.IsAbleToGraveAsCost,player,LOCATION_HAND+LOCATION_ONFIELD,0,count,aux.BlackThreadHandler)
			end

		end
		function Duel.IsExistingMatchingCard(...)

			if not aux.BlackThreadUsing then
				return diemc(...)
			else
				return true
			end

		end
		function Duel.GetLP(...)

			if not aux.BlackThreadUsing then
				return dgl(...)
			else
				return true
			end

		end

		local croc=Card.RemoveOverlayCard
		local ddh=Duel.DiscardHand
		local dstg=Duel.SendtoGrave
		local dh=Duel.Hint
		local dsmc=Duel.SelectMatchingCard
		--local gfs=Group.FilterSelect
		local dre=Duel.RegisterEffect
		local dr=Duel.Remove
		local dplc=Duel.PayLPCost

		function Card.RemoveOverlayCard(card,player,min,max,reason)

			if not aux.BlackThreadUsing then
				return croc(card,player,min,max,reason)
			else
				dh(HINT_SELECTMSG,player,HINTMSG_TOGRAVE)
				local group=dsmc(player,Card.IsAbleToGraveAsCost,player,LOCATION_HAND+LOCATION_ONFIELD,0,min,max,aux.BlackThreadHandler)
				return dstg(group,REASON_COST)
			end

		end
		function Duel.DiscardHand(...)

			if not aux.BlackThreadUsing then
				return ddh(...)
			else
				return 0
			end

		end
		function Duel.SendtoGrave(...)

			if not aux.BlackThreadUsing then
				return dstg(...)
			else
				return 0
			end

		end
		function Duel.Hint(...)

			if not aux.BlackThreadUsing then
				return dh(...)
			else
				return nil
			end

		end
		function Duel.SelectMatchingCard(...)

			if not aux.BlackThreadUsing then
				return dsmc(...)
			else
				return 0
			end

		end
		function Duel.RegisterEffect(...)

			if not aux.BlackThreadUsing then
				return dre(...)
			else
				return false
			end

		end
		function Duel.Remove(...)

			if not aux.BlackThreadUsing then
				return dr(...)
			else
				return 0
			end

		end
		function Duel.PayLPCost(...)

			if not aux.BlackThreadUsing then
				return dplc(...)
			else
				return 0
			end	

		end

	end

end