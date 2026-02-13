# System Architect Agent Research - Findings

## Best Practices from Web Research

### Architecture Decision Records (ADRs)

**Source:** https://github.com/joelparkerhenderson/architecture-decision-record

**Key Concept:**
ADR captures an important architecture decision made along with its context and consequences.

**ADR Structure:**
1. **Title** - Short noun phrase
2. **Status** - Proposed, Accepted, Deprecated, Superseded
3. **Context** - Forces at play (technical, political, social, project)
4. **Decision** - Response to forces
5. **Consequences** - Trade-offs and implications

**Best Practices:**
- Capture every factor influencing a decision
- Search for exhaustive list of alternatives first
- Document trade-offs explicitly
- Link ADRs to affected components

### C4 Model for Architecture Diagrams

**Sources:**
- https://revision.app/blog/practical-c4-modeling-tips
- https://visual-c4.com/blog/c4-model-architecture-adr-integration

**C4 Levels:**
1. **Context** - System in its environment
2. **Container** - High-level technical building blocks
3. **Component** - Components within containers
4. **Code** - Class/interface level (optional)

**Best Practices:**
- Start with Context diagram (highest level)
- Use Container diagrams for deployment planning
- Component diagrams for detailed design
- Link ADRs to affected containers/components
- Use "Diagram and Documentation as Code" approach

### Architecture Documentation Components

**Sources:**
- https://bool.dev/blog/detail/architecture-documentation-best-practice
- https://lucamezzalira.medium.com/how-to-document-software-architecture-techniques-and-best-practices-2556b1915850

**Essential Sections:**

1. **System Overview**
   - Purpose and scope
   - Key stakeholders
   - Quality attributes (performance, security, scalability)

2. **Architecture Decisions**
   - ADRs for major choices
   - Technology stack with rationale
   - Trade-offs documented

3. **Component Design**
   - C4 diagrams
   - Component responsibilities
   - Interfaces and contracts

4. **Data Architecture**
   - Data models and schemas
   - Data flow diagrams
   - Database choices and rationale

5. **Integration Architecture**
   - API specifications
   - Integration patterns
   - Service boundaries

6. **Non-Functional Requirements (NFR) Coverage**
   - Performance targets
   - Security measures
   - Scalability patterns
   - Resilience planning

7. **Deployment Architecture**
   - Infrastructure design
   - CI/CD pipeline
   - Environment configuration

### GitHub Skills Findings

**Source:** Various GitHub repos (aj-geddes, adrianpuiu, VoltAgent)

**Common Patterns in Architecture Skills:**

- **Knowledge-enhanced expert** in software architecture, system design, and architectural patterns
- **Specializes in:**
  - Evaluating architectural decisions
  - Identifying design improvements
  - Ensuring scalable, maintainable architecture
- **Generates:**
  - Complete system architecture with component maps
  - Data flows and integration specifications
  - Implementation plans with hierarchical task breakdown
  - Requirement tracing

**Architecture Validation Checklist:**
- Scalability analysis
- Technology stack evaluation
- Evolutionary architecture assessment
- Module organization review
- Dependency analysis
- Service boundary definition
- Data consistency patterns

## Key Takeaways for Our Architecture Expert Subagent

1. **Use ADR pattern** - Document decisions with context and consequences
2. **C4 diagrams** - Provide visual architecture at multiple levels
3. **NFR coverage** - Ensure performance, security, scalability addressed
4. **Technology stack justification** - Explain choices with trade-offs
5. **Data architecture** - Schema design and data flow
6. **API specifications** - Clear contracts between components
7. **Deployment strategy** - Infrastructure and CI/CD considerations

## Adaptation for Ralph-Planner Workflow

Our Architecture Expert subagent should:

**Input:**
- design.md (from brainstorming)
- PRD.md (from Product Manager)

**Output:** ARCHITECTURE.md with:

1. **System Overview**
   - Architecture vision
   - Quality attributes (from NFRs in PRD)

2. **Architecture Decisions (ADRs)**
   - Major tech stack choices
   - Pattern selections (monolith/microservices/etc.)
   - Trade-offs documented

3. **Component Design**
   - C4 Container diagram (text description)
   - Component breakdown
   - Responsibilities and boundaries

4. **Data Architecture**
   - Database schema (tables, relationships)
   - Data flow diagrams (text description)
   - Migration strategy if needed

5. **API Specifications**
   - Endpoint definitions
   - Request/response formats
   - Authentication/authorization approach

6. **Integration Points**
   - External services
   - Internal service communication
   - Event flows

7. **NFR Coverage**
   - Performance strategy
   - Security measures
   - Scalability patterns
   - Error handling approach

8. **Deployment Architecture**
   - Infrastructure needs
   - Environment configuration
   - CI/CD considerations

9. **Implementation Guidance**
   - File structure recommendations
   - Naming conventions
   - Code organization patterns

This ARCHITECTURE.md will then feed into:
- Final epic/spec assembly (with detailed implementation tasks)
- Ralph loop execution (with architectural context)

## Sources

- [Architecture Decision Records](https://github.com/joelparkerhenderson/architecture-decision-record)
- [C4 Model Architecture](https://visual-c4.com/blog/c4-model-architecture-adr-integration)
- [Best Practices for Architecture Documentation](https://bool.dev/blog/detail/architecture-documentation-best-practice)
- [How to Document Software Architecture](https://lucamezzalira.medium.com/how-to-document-software-architecture-techniques-and-best-practices-2556b1915850)
- [GitHub Architecture Skills](https://github.com/alirezarezvani/claude-skills)
