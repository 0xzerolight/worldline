// "Inside a tube": one tube built from separate layers (shell, ten cathodes, mesh,
// glass), each its own HTML layer so CSS can fan them out in 3D.
import { Digits } from "./widget.js";
import { defsInner, stack, unlit, lit, coreColour, DEFAULTS } from "./svg.js";

const P = "wx";
const VIEW = `viewBox="-20 -20 140 240"`;

export class Explode {
    constructor(host, button, opts = {}, digit = 4) {
        this.opts = { ...DEFAULTS, ...opts };
        this.digit = digit;
        this.host = host;
        this.button = button;
        // Shared defs live in a hidden svg; the layers reference them by id.
        this.defs = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        this.defs.setAttribute("aria-hidden", "true");
        this.defs.classList.add("defs");
        document.body.append(this.defs);

        const layer = (cls, z, label = "") => {
            const div = document.createElement("div");
            div.className = `layer ${cls}`;
            div.style.setProperty("--z", z);
            div.innerHTML = `<svg ${VIEW} aria-hidden="true"></svg>${label}`;
            host.append(div);
            return div.firstChild;
        };
        // Back to front: z runs from -6 (shell) to +6 (front glass).
        this.back = layer("shell", -6);
        this.cathodes = [...stack].reverse().map(c => {
            const z = 4.5 - c.i;
            return { c, svg: layer("cathode", z, `<span class="label">${c.d}</span>`) };
        });
        this.mesh = layer("mesh", 5.5);
        this.front = layer("glass", 6);

        host.addEventListener("click", e => {
            const d = e.target.closest?.("[data-d]")?.dataset.d;
            if (d !== undefined)
                this.light(+d);
        });
        button.addEventListener("click", () => this.toggle());
        this.render();
    }

    setOptions(opts) {
        Object.assign(this.opts, opts);
        this.render();
    }

    light(d) {
        this.digit = d;
        this.render();
    }

    toggle() {
        const apart = this.host.classList.toggle("apart");
        this.button.textContent = apart ? "Put it back together" : "Take it apart";
        this.button.setAttribute("aria-pressed", apart);
    }

    render() {
        const o = this.opts, core = coreColour(o.colour);
        const depth = Digits.stack.indexOf(this.digit);
        this.defs.innerHTML = `<defs>${defsInner(o, P)}</defs>`;
        this.back.innerHTML = `<use href="#${P}-back"/><use href="#${P}-wash"/>`;
        for (const { c, svg } of this.cathodes) {
            const shape = c.d === this.digit ? lit(P, o, core, c.d, false) : unlit(P, o, c, c.i < depth);
            // A wide invisible stroke to tap, so thin wires behind others are easy to hit.
            svg.innerHTML = `<g fill="none" stroke-linecap="round" stroke-linejoin="round">${shape}` +
                `<use href="#${P}-c${c.d}" stroke="transparent" stroke-width="10" pointer-events="stroke" data-d="${c.d}"/></g>`;
            svg.parentElement.classList.toggle("on", c.d === this.digit);
        }
        this.mesh.innerHTML = o.showMesh ? `<use href="#${P}-mesh"/>` : "";
        this.front.innerHTML = `<use href="#${P}-front"/><use href="#${P}-catch"/>`;
    }
}
